import assert from "node:assert/strict";
import { randomUUID } from "node:crypto";
import { after, describe, it } from "node:test";

import type { MembershipRole } from "@prisma/client";

import { GENESIS_HASH } from "@/lib/integrity/hash";

import { seed } from "../../prisma/seed";
import { recordExport, verifyAuditChain } from "./audit-log";
import { defaultPaymentBands } from "./approval-rules";
import { decideApproval, submitApproval } from "./approval";
import { disconnectDatabases, ownerDb, withTenant, type AppTx } from "./db";
import { AccessError } from "./errors";
import { postJournal, verifyJournalChain } from "./journal";
import { lockPeriod, reopenPeriod, softClosePeriod } from "./periods";
import { confirmSignIn, requestSignIn, resolveSession } from "./session";
import { applySession, type TenantContext } from "./tenant";

const CHAINS = ["JOURNAL", "STOCK", "SHARE", "AUDIT"] as const;

function context(input: {
  organizationId: string;
  userId: string;
  role: MembershipRole;
  partyId?: string | null;
}): TenantContext {
  return {
    organizationId: input.organizationId,
    userId: input.userId,
    role: input.role,
    partyId: input.partyId ?? null,
    ipAddress: "203.0.113.10",
    userAgent: "SiteLedgerTest/1",
    deviceId: null,
    requestId: "req-test",
  };
}

async function makeFirm(prefix: string) {
  const slug = `${prefix}-${randomUUID().slice(0, 8)}`;
  const org = await ownerDb.organization.create({
    data: {
      slug,
      legalName: `${prefix} Developers`,
      displayName: prefix,
      stateCode: "36",
      city: "Hyderabad",
    },
  });
  await ownerDb.chainHead.createMany({
    data: CHAINS.map((chain) => ({
      organizationId: org.id,
      chain,
      lastHash: GENESIS_HASH,
      lastSequence: 0,
    })),
  });

  async function member(role: MembershipRole, partyId?: string) {
    const email = `${role.toLowerCase()}.${randomUUID().slice(0, 8)}@${slug}.example`;
    const user = await ownerDb.user.create({
      data: { email, name: `${prefix} ${role}` },
    });
    await ownerDb.membership.create({
      data: {
        organizationId: org.id,
        userId: user.id,
        role,
        partyId: partyId ?? null,
      },
    });
    return {
      user,
      ctx: context({ organizationId: org.id, userId: user.id, role, partyId }),
    };
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

describe("auth, tenants, audit, and the hash chain", () => {
  after(async () => {
    await disconnectDatabases();
  });

  it("blocks an auditor write, blocks another firm's rows, and refuses deletes", async () => {
    const alpha = await makeFirm("Alpha");
    const beta = await makeFirm("Beta");
    const alphaOwner = await alpha.member("OWNER");
    const alphaFinance = await alpha.member("FINANCE");
    const alphaAuditor = await alpha.member("AUDITOR");
    const betaFinance = await beta.member("FINANCE");

    const alphaParty = await withTenant(alphaFinance.ctx, (tx) =>
      tx.party.create({
        data: {
          organizationId: alpha.org.id,
          kind: "COMPANY",
          legalName: "Alpha Timber",
          displayName: "Alpha Timber",
          isVendor: true,
        },
      }),
    );
    const betaParty = await withTenant(betaFinance.ctx, (tx) =>
      tx.party.create({
        data: {
          organizationId: beta.org.id,
          kind: "COMPANY",
          legalName: "Beta Stone",
          displayName: "Beta Stone",
          isVendor: true,
        },
      }),
    );

    const visible = await withTenant(alphaFinance.ctx, (tx) => tx.party.findMany());
    assert.deepEqual(
      visible.map((party) => party.id),
      [alphaParty.id],
    );
    const hidden = await withTenant(alphaFinance.ctx, (tx) =>
      tx.party.findMany({ where: { id: betaParty.id } }),
    );
    assert.equal(hidden.length, 0);

    const forged = await messageOf(() =>
      withTenant(
        context({
          organizationId: beta.org.id,
          userId: alphaFinance.user.id,
          role: "FINANCE",
        }),
        (tx) => tx.party.findMany(),
      ),
    );
    assert.match(forged, /no active membership/);

    const auditorWrite = await messageOf(() =>
      withTenant(alphaAuditor.ctx, (tx) =>
        tx.party.update({
          where: { id: alphaParty.id },
          data: { displayName: "Rewritten" },
        }),
      ),
    );
    assert.match(auditorWrite, /AUDITOR cannot write/);

    const auditorSql = await messageOf(() =>
      withTenant(alphaAuditor.ctx, (tx) =>
        tx.$executeRaw`UPDATE parties SET display_name = 'smuggled' WHERE id = ${alphaParty.id}::uuid`,
      ),
    );
    assert.match(auditorSql, /row-level security/);

    const unchanged = await withTenant(alphaOwner.ctx, (tx) =>
      tx.party.findUniqueOrThrow({ where: { id: alphaParty.id } }),
    );
    assert.equal(unchanged.displayName, "Alpha Timber");

    await recordExport(alphaAuditor.ctx, { entityType: "PARTY", entityId: alphaParty.id });
    const exported = await withTenant(alphaAuditor.ctx, (tx) =>
      tx.auditEvent.findMany({ where: { action: "EXPORT", entityId: alphaParty.id } }),
    );
    assert.equal(exported.length, 1);
    assert.equal(exported[0]?.actorId, alphaAuditor.user.id);
    assert.equal(exported[0]?.ipAddress, "203.0.113.10");
    assert.equal(exported[0]?.userAgent, "SiteLedgerTest/1");

    const auditUpdate = await messageOf(() =>
      ownerDb.auditEvent.update({
        where: { id: exported[0]!.id },
        data: { ipAddress: "198.51.100.20" },
      }),
    );
    assert.match(auditUpdate, /append-only/);

    const auditDelete = await messageOf(() =>
      ownerDb.auditEvent.delete({ where: { id: exported[0]!.id } }),
    );
    assert.match(auditDelete, /append-only/);

    const modelDelete = await messageOf(() =>
      withTenant(alphaFinance.ctx, (tx) => tx.party.delete({ where: { id: alphaParty.id } })),
    );
    assert.match(modelDelete, /cannot be deleted/);

    const sqlDelete = await messageOf(() =>
      withTenant(alphaFinance.ctx, (tx) =>
        tx.$executeRaw`DELETE FROM parties WHERE id = ${alphaParty.id}::uuid`,
      ),
    );
    assert.match(sqlDelete, /permission denied/);

    const stillThere = await ownerDb.party.findUnique({ where: { id: alphaParty.id } });
    assert.equal(stillThere?.deletedAt, null);
  });

  it("records old and new values on a write and keeps the audit chain intact", async () => {
    const firm = await makeFirm("Cedar");
    const finance = await firm.member("FINANCE");
    const party = await withTenant(finance.ctx, (tx) =>
      tx.party.create({
        data: {
          organizationId: firm.org.id,
          kind: "INDIVIDUAL",
          legalName: "Old Name",
          displayName: "Old Name",
        },
      }),
    );
    await withTenant(finance.ctx, (tx) =>
      tx.party.update({
        where: { id: party.id },
        data: { displayName: "New Name" },
      }),
    );
    const updated = await withTenant(finance.ctx, (tx) =>
      tx.auditEvent.findFirstOrThrow({
        where: { entityId: party.id, action: "UPDATE" },
      }),
    );
    assert.equal(updated.actorId, finance.user.id);
    assert.equal(updated.ipAddress, "203.0.113.10");
    assert.equal(updated.userAgent, "SiteLedgerTest/1");
    assert.equal((updated.before as { displayName: string }).displayName, "Old Name");
    assert.equal((updated.after as { displayName: string }).displayName, "New Name");

    const report = await withTenant(finance.ctx, (tx) => verifyAuditChain(tx as unknown as AppTx, firm.org.id));
    assert.deepEqual(report, { ok: true });
  });

  it("hides another project's lead from sales and another party's row from a vendor", async () => {
    const firm = await makeFirm("Delta");
    const owner = await firm.member("OWNER");
    const east = await withTenant(owner.ctx, (tx) =>
      tx.project.create({
        data: {
          organizationId: firm.org.id,
          code: "EAST",
          name: "East Court",
          stateCode: "36",
        },
      }),
    );
    const west = await withTenant(owner.ctx, (tx) =>
      tx.project.create({
        data: {
          organizationId: firm.org.id,
          code: "WEST",
          name: "West Court",
          stateCode: "36",
        },
      }),
    );
    await withTenant(owner.ctx, (tx) =>
      tx.lead.create({
        data: { organizationId: firm.org.id, projectId: east.id, name: "East lead" },
      }),
    );
    await withTenant(owner.ctx, (tx) =>
      tx.lead.create({
        data: { organizationId: firm.org.id, projectId: west.id, name: "West lead" },
      }),
    );
    const salesUser = await firm.member("SALES");
    await withTenant(owner.ctx, (tx) =>
      tx.projectAssignment.create({
        data: {
          organizationId: firm.org.id,
          projectId: east.id,
          userId: salesUser.user.id,
          createdById: owner.user.id,
        },
      }),
    );
    const leads = await withTenant(salesUser.ctx, (tx) => tx.lead.findMany());
    assert.deepEqual(
      leads.map((lead) => lead.name),
      ["East lead"],
    );

    const ownParty = await ownerDb.party.create({
      data: {
        organizationId: firm.org.id,
        kind: "COMPANY",
        legalName: "Own Supplies",
        displayName: "Own Supplies",
        isVendor: true,
      },
    });
    await ownerDb.party.create({
      data: {
        organizationId: firm.org.id,
        kind: "COMPANY",
        legalName: "Other Supplies",
        displayName: "Other Supplies",
        isVendor: true,
      },
    });
    const vendor = await firm.member("VENDOR", ownParty.id);
    const parties = await withTenant(vendor.ctx, (tx) => tx.party.findMany());
    assert.deepEqual(
      parties.map((party) => party.id),
      [ownParty.id],
    );
    const vendorWrite = await messageOf(() =>
      withTenant(vendor.ctx, (tx) =>
        tx.party.update({ where: { id: ownParty.id }, data: { displayName: "Changed" } }),
      ),
    );
    assert.match(vendorWrite, /VENDOR cannot write/);
  });

  it("auto-approves a small amount, refuses a maker as checker, and reopens only for the owner", async () => {
    const firm = await makeFirm("Elm");
    const owner = await firm.member("OWNER");
    const finance = await firm.member("FINANCE");
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
            createdById: owner.user.id,
          },
        });
      }
    });

    const small = await submitApproval(finance.ctx, {
      entityType: "PAYMENT",
      entityId: randomUUID(),
      amountPaise: 50_000n,
    });
    assert.equal(small.status, "APPROVED");
    assert.equal(small.actions[0]?.actorId, null);

    const large = await submitApproval(finance.ctx, {
      entityType: "PAYMENT",
      entityId: randomUUID(),
      amountPaise: 2_000_000n,
    });
    assert.equal(large.status, "PENDING");
    const selfCheck = await messageOf(() =>
      decideApproval(finance.ctx, { requestId: large.id, decision: "APPROVED" }),
    );
    assert.match(selfCheck, /maker cannot be the checker/);
    const approved = await decideApproval(owner.ctx, {
      requestId: large.id,
      decision: "APPROVED",
    });
    assert.equal(approved.status, "APPROVED");

    const year = await withTenant(finance.ctx, (tx) =>
      tx.fiscalYear.create({
        data: {
          organizationId: firm.org.id,
          name: "FY test",
          startsOn: new Date("2026-04-01T00:00:00.000Z"),
          endsOn: new Date("2027-03-31T00:00:00.000Z"),
        },
      }),
    );
    const period = await withTenant(finance.ctx, (tx) =>
      tx.accountingPeriod.create({
        data: {
          organizationId: firm.org.id,
          fiscalYearId: year.id,
          name: "April test",
          startsOn: new Date("2026-04-01T00:00:00.000Z"),
          endsOn: new Date("2026-04-30T00:00:00.000Z"),
        },
      }),
    );
    await softClosePeriod(finance.ctx, period.id, "Month is done");
    await lockPeriod(finance.ctx, period.id, "Books are closed");
    const financeReopen = await messageOf(() =>
      reopenPeriod(finance.ctx, period.id, "Please reopen"),
    );
    assert.match(financeReopen, /cannot period.reopen/);
    await reopenPeriod(owner.ctx, period.id, "A bill was left out");
    const events = await withTenant(owner.ctx, (tx) =>
      tx.periodLockEvent.findMany({ where: { periodId: period.id }, orderBy: { occurredAt: "asc" } }),
    );
    assert.deepEqual(
      events.map((event) => event.action),
      ["SOFT_CLOSE", "LOCK", "REOPEN"],
    );
    const reopen = events[2];
    assert.equal(reopen?.actorId, owner.user.id);
    assert.ok(reopen?.approvalRequestId);
    const opened = await withTenant(owner.ctx, (tx) =>
      tx.accountingPeriod.findUniqueOrThrow({ where: { id: period.id } }),
    );
    assert.equal(opened.status, "OPEN");
  });

  it("detects a journal whose narration was changed under the hash", async () => {
    const firm = await makeFirm("Fir");
    const finance = await firm.member("FINANCE");
    const cash = await withTenant(finance.ctx, (tx) =>
      tx.glAccount.create({
        data: {
          organizationId: firm.org.id,
          code: "1000",
          name: "Cash",
          accountType: "ASSET",
          normalBalance: "DEBIT",
        },
      }),
    );
    const equity = await withTenant(finance.ctx, (tx) =>
      tx.glAccount.create({
        data: {
          organizationId: firm.org.id,
          code: "3000",
          name: "Partner capital",
          accountType: "EQUITY",
          normalBalance: "CREDIT",
        },
      }),
    );
    const year = await withTenant(finance.ctx, (tx) =>
      tx.fiscalYear.create({
        data: {
          organizationId: firm.org.id,
          name: "FY journal",
          startsOn: new Date("2026-04-01T00:00:00.000Z"),
          endsOn: new Date("2027-03-31T00:00:00.000Z"),
        },
      }),
    );
    const open = await withTenant(finance.ctx, (tx) =>
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
    const locked = await withTenant(finance.ctx, (tx) =>
      tx.accountingPeriod.create({
        data: {
          organizationId: firm.org.id,
          fiscalYearId: year.id,
          name: "May",
          startsOn: new Date("2026-05-01T00:00:00.000Z"),
          endsOn: new Date("2026-05-31T00:00:00.000Z"),
          status: "LOCKED",
        },
      }),
    );
    const refused = await messageOf(() =>
      postJournal(finance.ctx, {
        periodId: locked.id,
        entryDate: new Date("2026-05-02T00:00:00.000Z"),
        narration: "Should not post",
        source: "MANUAL",
        lines: [
          { glAccountId: cash.id, debitPaise: 100n, creditPaise: 0n },
          { glAccountId: equity.id, debitPaise: 0n, creditPaise: 100n },
        ],
      }),
    );
    assert.match(refused, /locked/);

    const lines = [
      { glAccountId: cash.id, debitPaise: 10_000n, creditPaise: 0n },
      { glAccountId: equity.id, debitPaise: 0n, creditPaise: 10_000n },
    ];
    const first = await postJournal(finance.ctx, {
      periodId: open.id,
      entryDate: new Date("2026-04-15T00:00:00.000Z"),
      narration: "Opening capital",
      source: "CAPITAL",
      lines,
    });
    await postJournal(finance.ctx, {
      periodId: open.id,
      entryDate: new Date("2026-04-16T00:00:00.000Z"),
      narration: "Second capital",
      source: "CAPITAL",
      lines,
    });
    const intact = await withTenant(finance.ctx, (tx) =>
      verifyJournalChain(tx as unknown as AppTx, firm.org.id),
    );
    assert.deepEqual(intact, { ok: true });

    const blocked = await messageOf(() =>
      ownerDb.journalEntry.update({
        where: { id: first.id },
        data: { narration: "tampered narration" },
      }),
    );
    assert.match(blocked, /immutable/);

    await ownerDb.$executeRaw`ALTER TABLE journal_entries DISABLE TRIGGER journal_entry_immutable`;
    try {
      await ownerDb.$executeRaw`
        UPDATE journal_entries
        SET narration = 'tampered narration'
        WHERE id = ${first.id}::uuid
      `;
    } finally {
      await ownerDb.$executeRaw`ALTER TABLE journal_entries ENABLE TRIGGER journal_entry_immutable`;
    }
    const tampered = await withTenant(finance.ctx, (tx) =>
      verifyJournalChain(tx as unknown as AppTx, firm.org.id),
    );
    assert.equal(tampered.ok, false);
    if (!tampered.ok) {
      assert.equal(tampered.sequence, 1);
      assert.match(tampered.reason, /payload/);
    }
  });

  it("loads the example firms once and signs a member in", async () => {
    await seed();
    await seed();
    const red = await ownerDb.organization.findUniqueOrThrow({ where: { slug: "red-earth" } });
    const blue = await ownerDb.organization.findUniqueOrThrow({ where: { slug: "blue-basin" } });
    const memberships = await ownerDb.membership.count({ where: { organizationId: red.id } });
    assert.equal(memberships, 8);
    const names = await ownerDb.party.findMany({
      where: { organizationId: { in: [red.id, blue.id] } },
      select: { displayName: true },
      orderBy: { displayName: "asc" },
    });
    assert.deepEqual(
      names.map((party) => party.displayName),
      ["Kaveri Cement", "Lotus Stone", "Nikhil Shetty"],
    );

    const { token } = await requestSignIn("dev.krishnan@red-earth.example");
    const signedIn = await confirmSignIn({
      email: "dev.krishnan@red-earth.example",
      token,
      ipAddress: "203.0.113.44",
      userAgent: "SiteLedgerTest/1",
    });
    const session = await resolveSession(signedIn.sessionToken);
    assert.equal(session?.user.email, "dev.krishnan@red-earth.example");
    assert.equal(session?.memberships[0]?.role, "FINANCE");
    assert.equal(session?.memberships[0]?.organizationName, "Red Earth");
    const login = await ownerDb.auditEvent.findFirst({
      where: { organizationId: red.id, action: "LOGIN", actorId: signedIn.userId },
    });
    assert.equal(login?.ipAddress, "203.0.113.44");
    const report = await ownerDb.$transaction(async (tx) => {
      await applySession(tx, context({ organizationId: red.id, userId: signedIn.userId, role: "FINANCE" }));
      return verifyAuditChain(tx, red.id);
    });
    assert.deepEqual(report, { ok: true });
  });
});
