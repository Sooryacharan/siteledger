"use server";

import { redirect } from "next/navigation";

import type { AccountType, NormalBalance } from "@prisma/client";

import { AccessError } from "@/server/errors";
import {
  addAccount,
  addBankAccount,
  askForPaymentApproval,
  decidePaymentApproval,
  movePeriod,
  openPeriod,
  postManualJournal,
} from "@/server/finance";
import { requireOffice } from "@/server/office";

function fail(path: string, error: unknown): never {
  const message = error instanceof Error ? error.message : "That did not save";
  redirect(`${path}?error=${encodeURIComponent(message)}`);
}

function isNextRedirect(error: unknown): boolean {
  return (
    typeof error === "object" &&
    error !== null &&
    "digest" in error &&
    String((error as { digest: unknown }).digest).startsWith("NEXT_REDIRECT")
  );
}

async function run(path: string, work: () => Promise<unknown>) {
  try {
    await work();
  } catch (error) {
    if (isNextRedirect(error)) throw error;
    if (error instanceof AccessError || error instanceof Error) fail(path, error);
    fail(path, error);
  }
  redirect(path);
}

export async function addAccountAction(formData: FormData) {
  const office = await requireOffice();
  await run("/finance/accounts", () =>
    addAccount(office.ctx, {
      code: String(formData.get("code") ?? ""),
      name: String(formData.get("name") ?? ""),
      accountType: String(formData.get("accountType") ?? "ASSET") as AccountType,
      normalBalance: String(formData.get("normalBalance") ?? "DEBIT") as NormalBalance,
    }),
  );
}

export async function postJournalAction(formData: FormData) {
  const office = await requireOffice();
  const lines = [1, 2, 3].map((index) => ({
    glAccountId: String(formData.get(`account${index}`) ?? ""),
    side: String(formData.get(`side${index}`) ?? "debit") as "debit" | "credit",
    rupees: String(formData.get(`rupees${index}`) ?? ""),
  }));
  await run("/finance/journals", () =>
    postManualJournal(office.ctx, {
      periodId: String(formData.get("periodId") ?? ""),
      entryDate: String(formData.get("entryDate") ?? ""),
      narration: String(formData.get("narration") ?? ""),
      lines,
    }),
  );
}

export async function openPeriodAction(formData: FormData) {
  const office = await requireOffice();
  await run("/finance/periods", () =>
    openPeriod(office.ctx, {
      name: String(formData.get("name") ?? ""),
      startsOn: String(formData.get("startsOn") ?? ""),
      endsOn: String(formData.get("endsOn") ?? ""),
      fiscalYearName: String(formData.get("fiscalYearName") ?? "FY 2026-27"),
    }),
  );
}

export async function movePeriodAction(formData: FormData) {
  const office = await requireOffice();
  const move = String(formData.get("move") ?? "") as "soft-close" | "lock" | "reopen";
  await run("/finance/periods", () =>
    movePeriod(office.ctx, {
      periodId: String(formData.get("periodId") ?? ""),
      move,
      reason: String(formData.get("reason") ?? ""),
    }),
  );
}

export async function addBankAction(formData: FormData) {
  const office = await requireOffice();
  await run("/finance/banks", () =>
    addBankAccount(office.ctx, {
      glAccountId: String(formData.get("glAccountId") ?? ""),
      displayName: String(formData.get("displayName") ?? ""),
      bankName: String(formData.get("bankName") ?? ""),
      accountNumber: String(formData.get("accountNumber") ?? ""),
      ifsc: String(formData.get("ifsc") ?? ""),
      isCash: formData.get("isCash") === "on",
    }),
  );
}

export async function askApprovalAction(formData: FormData) {
  const office = await requireOffice();
  await run("/finance/approvals", () => askForPaymentApproval(office.ctx, String(formData.get("rupees") ?? "")));
}

export async function decideApprovalAction(formData: FormData) {
  const office = await requireOffice();
  const decision = String(formData.get("decision") ?? "APPROVED") as "APPROVED" | "REJECTED";
  await run("/finance/approvals", () =>
    decidePaymentApproval(office.ctx, {
      requestId: String(formData.get("requestId") ?? ""),
      decision,
      reason: String(formData.get("reason") ?? ""),
    }),
  );
}
