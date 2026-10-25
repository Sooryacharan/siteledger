import { randomUUID } from "node:crypto";

import type { JournalSource, Prisma } from "@prisma/client";

import { journalEntryHash } from "@/lib/integrity/hash";

import { findChainBreak, type ChainReport } from "./chain";
import { withTenant } from "./db";
import { AccessError } from "./errors";
import { assertCan } from "./permissions";
import { tenantStore, type TenantContext } from "./tenant";

export type JournalLineInput = {
  glAccountId: string;
  debitPaise: bigint;
  creditPaise: bigint;
  projectId?: string | null;
  narration?: string | null;
};

export type JournalInput = {
  periodId: string;
  entryDate: Date;
  narration: string;
  source: JournalSource;
  sourceId?: string | null;
  lines: JournalLineInput[];
};

type LockRow = { last_hash: string; last_sequence: number };

export function calendarDate(value: Date): string {
  return value.toISOString().slice(0, 10);
}

export function assertJournalLines(lines: JournalLineInput[]): void {
  if (lines.length < 2) {
    throw new AccessError("a journal entry needs at least two lines", "CHAIN");
  }
  let debit = 0n;
  let credit = 0n;
  for (const line of lines) {
    if (line.debitPaise < 0n || line.creditPaise < 0n) {
      throw new AccessError("a journal line cannot be negative", "CHAIN");
    }
    if (line.debitPaise > 0n && line.creditPaise > 0n) {
      throw new AccessError("a journal line is either money in or money out, not both", "CHAIN");
    }
    if (line.debitPaise === 0n && line.creditPaise === 0n) {
      throw new AccessError("a journal line needs an amount", "CHAIN");
    }
    debit += line.debitPaise;
    credit += line.creditPaise;
  }
  if (debit !== credit || debit === 0n) {
    throw new AccessError("journal lines do not balance", "CHAIN");
  }
}

export async function postJournal(ctx: TenantContext, input: JournalInput) {
  assertCan(ctx.role, "write");
  assertJournalLines(input.lines);
  return withTenant(ctx, async (tx) => {
    const period = await tx.accountingPeriod.findUnique({ where: { id: input.periodId } });
    if (!period) {
      throw new AccessError("that accounting period is not in this firm", "PERIOD");
    }
    if (period.status === "LOCKED") {
      throw new AccessError("this accounting period is locked", "PERIOD");
    }
    const entryDay = calendarDate(input.entryDate);
    if (entryDay < calendarDate(period.startsOn) || entryDay > calendarDate(period.endsOn)) {
      throw new AccessError("the entry date is outside the accounting period", "PERIOD");
    }

    const accountIds = [...new Set(input.lines.map((line) => line.glAccountId))];
    const accounts = await tx.glAccount.findMany({ where: { id: { in: accountIds } } });
    if (accounts.length !== accountIds.length) {
      throw new AccessError("a journal line uses an account from another firm", "TENANT");
    }

    const locked = await tx.$queryRaw<LockRow[]>`
      SELECT last_hash, last_sequence
      FROM app.lock_chain_head(${ctx.organizationId}::uuid, ${"JOURNAL"})
    `;
    const head = locked[0];
    if (!head) {
      throw new AccessError("this firm has no journal chain head", "CHAIN");
    }
    const sequence = Number(head.last_sequence) + 1;
    const entryId = randomUUID();
    const numbered = input.lines.map((line, index) => ({ ...line, lineNumber: index + 1 }));
    const { hash } = journalEntryHash({
      prevHash: head.last_hash,
      organizationId: ctx.organizationId,
      entryId,
      entryDate: entryDay,
      narration: input.narration,
      source: input.source,
      sourceId: input.sourceId,
      lines: numbered.map((line) => ({
        lineNumber: line.lineNumber,
        glAccountId: line.glAccountId,
        debitPaise: line.debitPaise,
        creditPaise: line.creditPaise,
        projectId: line.projectId,
      })),
    });

    const store = tenantStore.getStore();
    if (store) store.actionOverride = "POST";
    let entry: { id: string; sequence: number | null; entryHash: string | null };
    try {
      entry = await tx.journalEntry.create({
        data: {
          id: entryId,
          organizationId: ctx.organizationId,
          periodId: input.periodId,
          postedById: ctx.userId,
          entryNumber: `JE-${String(sequence).padStart(6, "0")}`,
          entryDate: input.entryDate,
          narration: input.narration,
          source: input.source,
          sourceId: input.sourceId,
          status: "POSTED",
          sequence,
          prevHash: head.last_hash,
          entryHash: hash,
          postedAt: new Date(),
          createdById: ctx.userId,
        },
      });
    } finally {
      if (store) store.actionOverride = null;
    }

    for (const line of numbered) {
      await tx.journalLine.create({
        data: {
          organizationId: ctx.organizationId,
          entryId,
          glAccountId: line.glAccountId,
          lineNumber: line.lineNumber,
          debitPaise: line.debitPaise,
          creditPaise: line.creditPaise,
          projectId: line.projectId,
          narration: line.narration,
        },
      });
    }

    await tx.$executeRaw`
      SELECT app.advance_chain_head(
        ${ctx.organizationId}::uuid,
        ${"JOURNAL"},
        ${hash},
        ${sequence}::integer
      )
    `;

    return entry;
  });
}

export async function verifyJournalChain(
  tx: Prisma.TransactionClient,
  organizationId: string,
): Promise<ChainReport> {
  const [entries, head] = await Promise.all([
    tx.journalEntry.findMany({
      where: { organizationId, status: { in: ["POSTED", "REVERSED"] } },
      orderBy: { sequence: "asc" },
      include: { lines: { orderBy: { lineNumber: "asc" } } },
    }),
    tx.chainHead.findUnique({
      where: { organizationId_chain: { organizationId, chain: "JOURNAL" } },
    }),
  ]);
  if (!head) {
    return { ok: false, sequence: null, reason: "journal chain head is missing" };
  }
  return findChainBreak({
    headHash: head.lastHash,
    headSequence: head.lastSequence,
    rows: entries.map((entry) => ({
      sequence: entry.sequence ?? 0,
      prevHash: entry.prevHash ?? "",
      entryHash: entry.entryHash ?? "",
      expectedHash: journalEntryHash({
        prevHash: entry.prevHash ?? "",
        organizationId,
        entryId: entry.id,
        entryDate: calendarDate(entry.entryDate),
        narration: entry.narration,
        source: entry.source,
        sourceId: entry.sourceId,
        lines: entry.lines.map((line) => ({
          lineNumber: line.lineNumber,
          glAccountId: line.glAccountId,
          debitPaise: line.debitPaise,
          creditPaise: line.creditPaise,
          projectId: line.projectId,
          costCentreId: line.costCentreId,
          partyId: line.partyId,
          unitId: line.unitId,
        })),
      }).hash,
    })),
  });
}
