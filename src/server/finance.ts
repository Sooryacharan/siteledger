import { randomUUID } from "node:crypto";

import type { AccountType, MembershipRole, NormalBalance, PeriodStatus } from "@prisma/client";

import { formatInrFromPaise, rupeesToPaise } from "@/lib/money/display";

import { decideApproval, submitApproval } from "./approval";
import { withTenant, type AppTx } from "./db";
import { AccessError } from "./errors";
import { postJournal } from "./journal";
import { lockPeriod, reopenPeriod, softClosePeriod } from "./periods";
import type { TenantContext } from "./tenant";

const FINANCE_ROLES = new Set<MembershipRole>(["OWNER", "FINANCE", "AUDITOR"]);

export function canOpenFinance(role: MembershipRole): boolean {
  return FINANCE_ROLES.has(role);
}

export function canWriteFinance(role: MembershipRole): boolean {
  return role === "OWNER" || role === "FINANCE";
}

function assertFinance(role: MembershipRole): void {
  if (!canOpenFinance(role)) {
    throw new AccessError("the books are for the owner, finance, and the auditor", "FORBIDDEN");
  }
}

function assertWrite(role: MembershipRole): void {
  if (!canWriteFinance(role)) {
    throw new AccessError(`${role} cannot change the books`, "FORBIDDEN");
  }
}

const IFSC = /^[A-Z]{4}0[A-Z0-9]{6}$/;

export type AccountView = {
  id: string;
  code: string;
  name: string;
  accountType: AccountType;
  normalBalance: NormalBalance;
  removed: boolean;
};

export async function listAccounts(ctx: TenantContext): Promise<AccountView[]> {
  assertFinance(ctx.role);
  return withTenant(ctx, async (tx) => {
    const rows = await tx.glAccount.findMany({
      where: { deletedAt: ctx.role === "AUDITOR" ? undefined : null, isGroup: false },
      orderBy: { code: "asc" },
    });
    return rows.map((row) => ({
      id: row.id,
      code: row.code,
      name: row.name,
      accountType: row.accountType,
      normalBalance: row.normalBalance,
      removed: row.deletedAt != null,
    }));
  });
}

export async function addAccount(
  ctx: TenantContext,
  input: { code: string; name: string; accountType: AccountType; normalBalance: NormalBalance },
) {
  assertWrite(ctx.role);
  const code = input.code.trim();
  const name = input.name.trim();
  if (!/^[0-9A-Z][0-9A-Z-]{1,11}$/.test(code)) {
    throw new AccessError("use a short account code, such as 1000", "FORBIDDEN");
  }
  if (name.length < 2) throw new AccessError("the account needs a name", "FORBIDDEN");
  return withTenant(ctx, (tx) =>
    tx.glAccount.create({
      data: {
        organizationId: ctx.organizationId,
        code,
        name,
        accountType: input.accountType,
        normalBalance: input.normalBalance,
      },
    }),
  );
}

export type JournalView = {
  id: string;
  entryNumber: string;
  entryDate: string;
  narration: string;
  status: string;
  totalPaise: bigint;
  totalLabel: string;
  lines: Array<{ account: string; debit: string; credit: string }>;
};

export async function listJournals(ctx: TenantContext): Promise<JournalView[]> {
  assertFinance(ctx.role);
  return withTenant(ctx, async (tx) => {
    const rows = await tx.journalEntry.findMany({
      where: { deletedAt: null, status: { in: ["POSTED", "REVERSED"] } },
      orderBy: { sequence: "desc" },
      include: { lines: { orderBy: { lineNumber: "asc" }, include: { glAccount: true } } },
    });
    return rows.map((row) => {
      const total = row.lines.reduce((sum, line) => sum + line.debitPaise, 0n);
      return {
        id: row.id,
        entryNumber: row.entryNumber,
        entryDate: row.entryDate.toISOString().slice(0, 10),
        narration: row.narration,
        status: row.status,
        totalPaise: total,
        totalLabel: formatInrFromPaise(total),
        lines: row.lines.map((line) => ({
          account: `${line.glAccount.code} ${line.glAccount.name}`,
          debit: line.debitPaise === 0n ? "" : formatInrFromPaise(line.debitPaise),
          credit: line.creditPaise === 0n ? "" : formatInrFromPaise(line.creditPaise),
        })),
      };
    });
  });
}

export async function postManualJournal(
  ctx: TenantContext,
  input: {
    periodId: string;
    entryDate: string;
    narration: string;
    lines: Array<{ glAccountId: string; side: "debit" | "credit"; rupees: string }>;
  },
) {
  assertWrite(ctx.role);
  const narration = input.narration.trim();
  if (narration.length < 3) throw new AccessError("say what this entry is for", "FORBIDDEN");
  const lines = input.lines
    .filter((line) => line.glAccountId && line.rupees.trim())
    .map((line) => {
      const paise = rupeesToPaise(line.rupees);
      if (paise === 0n) throw new AccessError("each line needs an amount", "CHAIN");
      return {
        glAccountId: line.glAccountId,
        debitPaise: line.side === "debit" ? paise : 0n,
        creditPaise: line.side === "credit" ? paise : 0n,
      };
    });
  return postJournal(ctx, {
    periodId: input.periodId,
    entryDate: new Date(`${input.entryDate}T00:00:00.000Z`),
    narration,
    source: "MANUAL",
    lines,
  });
}

export type PeriodView = {
  id: string;
  name: string;
  startsOn: string;
  endsOn: string;
  status: PeriodStatus;
};

export async function listPeriods(ctx: TenantContext): Promise<PeriodView[]> {
  assertFinance(ctx.role);
  return withTenant(ctx, async (tx) => {
    const rows = await tx.accountingPeriod.findMany({ orderBy: { startsOn: "asc" } });
    return rows.map((row) => ({
      id: row.id,
      name: row.name,
      startsOn: row.startsOn.toISOString().slice(0, 10),
      endsOn: row.endsOn.toISOString().slice(0, 10),
      status: row.status,
    }));
  });
}

export async function openPeriod(
  ctx: TenantContext,
  input: { name: string; startsOn: string; endsOn: string; fiscalYearName: string },
) {
  assertWrite(ctx.role);
  const name = input.name.trim();
  if (name.length < 3) throw new AccessError("the period needs a name", "PERIOD");
  return withTenant(ctx, async (tx) => {
    const startsOn = new Date(`${input.startsOn}T00:00:00.000Z`);
    const endsOn = new Date(`${input.endsOn}T00:00:00.000Z`);
    if (!(startsOn < endsOn)) throw new AccessError("the period must end after it starts", "PERIOD");
    let year = await tx.fiscalYear.findFirst({
      where: { name: input.fiscalYearName.trim() },
    });
    if (!year) {
      year = await tx.fiscalYear.create({
        data: {
          organizationId: ctx.organizationId,
          name: input.fiscalYearName.trim(),
          startsOn,
          endsOn,
        },
      });
    }
    return tx.accountingPeriod.create({
      data: {
        organizationId: ctx.organizationId,
        fiscalYearId: year.id,
        name,
        startsOn,
        endsOn,
      },
    });
  });
}

export async function movePeriod(
  ctx: TenantContext,
  input: { periodId: string; move: "soft-close" | "lock" | "reopen"; reason: string },
) {
  if (input.move === "reopen") return reopenPeriod(ctx, input.periodId, input.reason);
  assertWrite(ctx.role);
  if (input.move === "soft-close") return softClosePeriod(ctx, input.periodId, input.reason.trim() || "Closing the books");
  return lockPeriod(ctx, input.periodId, input.reason.trim() || "Books are locked");
}

export type BankView = {
  id: string;
  displayName: string;
  bankName: string | null;
  accountNumber: string | null;
  ifsc: string | null;
  isCash: boolean;
  accountCode: string;
  balanceLabel: string;
};

export async function listBanks(ctx: TenantContext): Promise<BankView[]> {
  assertFinance(ctx.role);
  return withTenant(ctx, async (tx) => {
    const rows = await tx.bankAccount.findMany({
      where: { deletedAt: ctx.role === "AUDITOR" ? undefined : null },
      include: { glAccount: true },
      orderBy: { displayName: "asc" },
    });
    const balances = await balancesByAccount(tx);
    return rows.map((row) => ({
      id: row.id,
      displayName: row.displayName,
      bankName: row.bankName,
      accountNumber: row.accountNumber,
      ifsc: row.ifsc,
      isCash: row.isCash,
      accountCode: row.glAccount.code,
      balanceLabel: formatInrFromPaise(balances.get(row.glAccountId) ?? 0n),
    }));
  });
}

async function balancesByAccount(tx: AppTx): Promise<Map<string, bigint>> {
  const lines = await tx.journalLine.findMany({
    where: { entry: { status: { in: ["POSTED", "REVERSED"] }, deletedAt: null } },
    select: { glAccountId: true, debitPaise: true, creditPaise: true },
  });
  const totals = new Map<string, bigint>();
  for (const line of lines) {
    const signed = line.debitPaise - line.creditPaise;
    totals.set(line.glAccountId, (totals.get(line.glAccountId) ?? 0n) + signed);
  }
  return totals;
}

export async function cashPosition(ctx: TenantContext): Promise<string> {
  assertFinance(ctx.role);
  return withTenant(ctx, async (tx) => {
    const banks = await tx.bankAccount.findMany({
      where: { deletedAt: null },
      select: { glAccountId: true },
    });
    const balances = await balancesByAccount(tx);
    let total = 0n;
    for (const bank of banks) total += balances.get(bank.glAccountId) ?? 0n;
    return formatInrFromPaise(total);
  });
}

export async function addBankAccount(
  ctx: TenantContext,
  input: {
    glAccountId: string;
    displayName: string;
    bankName: string;
    accountNumber: string;
    ifsc: string;
    isCash: boolean;
  },
) {
  assertWrite(ctx.role);
  const displayName = input.displayName.trim();
  if (displayName.length < 2) throw new AccessError("the account needs a name people will recognise", "FORBIDDEN");
  const ifsc = input.ifsc.trim().toUpperCase();
  if (!input.isCash && !IFSC.test(ifsc)) {
    throw new AccessError("the IFSC should look like ABCD0123456", "FORBIDDEN");
  }
  return withTenant(ctx, async (tx) => {
    const account = await tx.glAccount.findFirst({
      where: { id: input.glAccountId, deletedAt: null, accountType: "ASSET" },
    });
    if (!account) throw new AccessError("choose a cash or bank account from the chart", "TENANT");
    return tx.bankAccount.create({
      data: {
        organizationId: ctx.organizationId,
        glAccountId: account.id,
        displayName,
        bankName: input.isCash ? null : input.bankName.trim() || null,
        accountNumber: input.isCash ? null : input.accountNumber.trim() || null,
        ifsc: input.isCash ? null : ifsc,
        isCash: input.isCash,
      },
    });
  });
}

export async function askForPaymentApproval(ctx: TenantContext, rupees: string) {
  assertWrite(ctx.role);
  const amountPaise = rupeesToPaise(rupees);
  if (amountPaise <= 0n) throw new AccessError("enter the amount to pay", "APPROVAL");
  return submitApproval(ctx, {
    entityType: "PAYMENT",
    entityId: randomUUID(),
    amountPaise,
  });
}

export async function decidePaymentApproval(
  ctx: TenantContext,
  input: { requestId: string; decision: "APPROVED" | "REJECTED"; reason: string },
) {
  return decideApproval(ctx, {
    requestId: input.requestId,
    decision: input.decision,
    comment: input.reason,
  });
}

export type ApprovalView = {
  id: string;
  amountLabel: string;
  status: string;
  step: number;
  requestedBy: string;
  reason: string | null;
};

export async function listPaymentApprovals(ctx: TenantContext): Promise<ApprovalView[]> {
  assertFinance(ctx.role);
  return withTenant(ctx, async (tx) => {
    const rows = await tx.approvalRequest.findMany({
      where: { entityType: "PAYMENT" },
      include: { requestedBy: true, actions: { orderBy: { actedAt: "desc" } } },
      orderBy: { createdAt: "desc" },
    });
    return rows.map((row) => ({
      id: row.id,
      amountLabel: formatInrFromPaise(row.amountPaise ?? 0n),
      status: row.status,
      step: row.currentStep,
      requestedBy: row.requestedBy.name ?? row.requestedBy.email,
      reason: row.actions.find((action) => action.comment)?.comment ?? null,
    }));
  });
}
