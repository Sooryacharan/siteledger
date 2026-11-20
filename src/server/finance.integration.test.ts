import assert from "node:assert/strict";
import { randomUUID } from "node:crypto";
import { after, describe, it } from "node:test";

import type { MembershipRole } from "@prisma/client";

import { GENESIS_HASH } from "@/lib/integrity/hash";

import { defaultPaymentBands } from "./approval-rules";
import { decideApproval, submitApproval } from "./approval";
import { disconnectDatabases, ownerDb, withTenant } from "./db";
import { addAccount, postManualJournal } from "./finance";
import { verifyJournalChain } from "./journal";
import { lockPeriod, softClosePeriod } from "./periods";
import type { TenantContext } from "./tenant";

const CHAINS = ["JOURNAL", "STOCK", "SHARE", "AUDIT"] as const;

function context(input: { organizationId: string; userId: string; role: MembershipRole }): TenantContext {
  return {
    organizationId: input.organizationId,
    userId: input.userId,
    role: input.role,
    partyId: null,
    ipAddress: "203.0.113.30",
    userAgent: "SiteLedgerFinance/1",
    deviceId: null,
    requestId: "req-finance",
  };
}

async function makeFirm(prefix: string) {
  const slug = `${prefix}-${randomUUID().slice(0, 8)}`;
  const org = await ownerDb.organization.create({
    data: { slug, legalName: `${prefix} Books`, displayName: prefix, stateCode: "36" },
  });
  await ownerDb.chainHead.createMany({
    data: CHAINS.map((chain) => ({ organizationId: org.id, chain, lastHash: GENESIS_HASH, lastSequence: 0 })),
  });
  async function member(role: MembershipRole) {
    const user = await ownerDb.user.create({
      data: { email: `${role.toLowerCase()}.${randomUUID().slice(0, 8)}@${slug}.example`, name: `${prefix} ${role}` },
    });
    await ownerDb.membership.create({ data: { organizationId: org.id, userId: user.id, role } });
    return { user, ctx: context({ organizationId: org.id, userId: user.id, role }) };
  }
  return { org, member };
}

async function messageOf(fn: () => Promise<unknown>): Promise<string> {
  try {
    await fn();
  } catch (error) {
    return error instanceof Error ? error.message : String(error);
  }
  throw new Error("expected the call to fail");
}

describe("finance books", () => {
  after(async () => {
    await disconnectDatabases();
  });

  it("posts a balanced journal and refuses one that does not balance or falls in a locked month", async () => {
    const firm = await makeFirm("Ledger");
    const owner = await firm.member("OWNER");
    const cash = await addAccount(owner.ctx, {
      code: "1000",
      name: "Cash box",
      accountType: "ASSET",
      normalBalance: "DEBIT",
    });
    const capital = await addAccount(owner.ctx, {
      code: "3000",
      name: "Owner's money",
      accountType: "EQUITY",
      normalBalance: "CREDIT",
    });
    const year = await withTenant(owner.ctx, (tx) =>
      tx.fiscalYear.create({
        data: {
          organizationId: firm.org.id,
          name: "FY test",
          startsOn: new Date("2026-04-01T00:00:00.000Z"),
          endsOn: new Date("2027-03-31T00:00:00.000Z"),
        },
      }),
    );
    const period = await withTenant(owner.ctx, (tx) =>
      tx.accountingPeriod.create({
        data: {
          organizationId: firm.org.id,
          fiscalYearId: year.id,
          name: "April",
          startsOn: new Date("2026-04-01T00:00:00.000Z"),
          endsOn: new Date("2026-04-30T00:00:00.000Z"),
        },
      }),
    );
    const unbalanced = await messageOf(() =>
      postManualJournal(owner.ctx, {
        periodId: period.id,
        entryDate: "2026-04-05",
        narration: "This should not post",
        lines: [
          { glAccountId: cash.id, side: "debit", rupees: "100" },
          { glAccountId: capital.id, side: "credit", rupees: "90" },
        ],
      }),
    );
    assert.match(unbalanced, /do not balance/);

    await postManualJournal(owner.ctx, {
      periodId: period.id,
      entryDate: "2026-04-05",
      narration: "Owner brought in cash",
      lines: [
        { glAccountId: cash.id, side: "debit", rupees: "100.50" },
        { glAccountId: capital.id, side: "credit", rupees: "100.50" },
      ],
    });
    const chain = await withTenant(owner.ctx, (tx) => verifyJournalChain(tx, firm.org.id));
    assert.deepEqual(chain, { ok: true });
    const line = await ownerDb.journalLine.findFirstOrThrow({ where: { glAccountId: cash.id } });
    assert.equal(line.debitPaise, 10050n);

    await softClosePeriod(owner.ctx, period.id, "Month is done");
    await lockPeriod(owner.ctx, period.id, "Books are closed");
    const locked = await messageOf(() =>
      postManualJournal(owner.ctx, {
        periodId: period.id,
        entryDate: "2026-04-06",
        narration: "Too late",
        lines: [
          { glAccountId: cash.id, side: "debit", rupees: "1" },
          { glAccountId: capital.id, side: "credit", rupees: "1" },
        ],
      }),
    );
    assert.match(locked, /locked/);
  });

  it("lets the only owner approve their own large payment after a written reason the auditor can read", async () => {
    const firm = await makeFirm("Solo");
    const owner = await firm.member("OWNER");
    const finance = await firm.member("FINANCE");
    const auditor = await firm.member("AUDITOR");
    await withTenant(owner.ctx, async (tx) => {
      for (const band of defaultPaymentBands()) {
        await tx.approvalPolicy.create({
          data: {
            organizationId: firm.org.id,
            entityType: "PAYMENT",
            minAmountPaise: band.minAmountPaise,
            maxAmountPaise: band.maxAmountPaise,
            stepOrder: band.stepOrder,
            approverRole: band.approverRole,
            autoApprove: band.autoApprove,
            plainLanguage: band.plainLanguage,
          },
        });
      }
    });
    const request = await submitApproval(owner.ctx, {
      entityType: "PAYMENT",
      entityId: randomUUID(),
      amountPaise: 10_000_000n,
    });
    await decideApproval(finance.ctx, { requestId: request.id, decision: "APPROVED" });
    const missing = await messageOf(() =>
      decideApproval(owner.ctx, { requestId: request.id, decision: "APPROVED", comment: "no" }),
    );
    assert.match(missing, /write a reason/);
    const approved = await decideApproval(owner.ctx, {
      requestId: request.id,
      decision: "APPROVED",
      comment: "The pour cannot wait for a second owner",
    });
    assert.equal(approved.status, "APPROVED");
    const audit = await withTenant(auditor.ctx, (tx) =>
      tx.auditEvent.findFirst({
        where: { action: "APPROVE", actorId: owner.user.id },
        orderBy: { sequence: "desc" },
      }),
    );
    assert.match(JSON.stringify(audit?.after), /pour cannot wait/);
  });
});
