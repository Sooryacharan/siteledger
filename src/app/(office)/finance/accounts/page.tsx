import Link from "next/link";

import { Button } from "@/components/ui/button";
import { Input } from "@/components/ui/input";
import { Label } from "@/components/ui/label";
import { OfficeFrame } from "@/components/office-frame";
import { canWriteFinance, listAccounts } from "@/server/finance";
import { requireOffice } from "@/server/office";

import { addAccountAction } from "../actions";

export const dynamic = "force-dynamic";

const TYPE_LABEL: Record<string, string> = {
  ASSET: "What the firm holds",
  LIABILITY: "What the firm owes",
  EQUITY: "Owner’s money in the firm",
  INCOME: "Money earned",
  EXPENSE: "Money spent",
};

export default async function AccountsPage({ searchParams }: { searchParams: { error?: string } }) {
  const office = await requireOffice();
  const accounts = await listAccounts(office.ctx);
  const canWrite = canWriteFinance(office.ctx.role);
  return (
    <OfficeFrame person={office.session.user.name ?? office.session.user.email} firm={office.membership.organizationName} role={office.membership.role}>
      <Link href="/finance" className="text-sm text-[#8a5a2a]">Back to the books</Link>
      <h1 className="text-3xl font-semibold">Chart of accounts</h1>
      <p className="max-w-2xl text-base leading-7 text-[#3f3a33]">These are the buckets every rupee is filed under. Add one when the books need a new name.</p>
      {searchParams.error ? <p className="rounded-2xl border border-[#e2b4a0] bg-white px-4 py-3 text-sm text-[#6b2d1a]">{searchParams.error}</p> : null}
      <ul className="flex flex-col gap-2">
        {accounts.map((account) => (
          <li key={account.id} className="flex items-center justify-between rounded-2xl bg-white px-4 py-3">
            <span className="font-medium">{account.code} · {account.name}{account.removed ? " · removed" : ""}</span>
            <span className="text-sm text-[#3f3a33]">{TYPE_LABEL[account.accountType] ?? account.accountType}</span>
          </li>
        ))}
      </ul>
      {canWrite ? (
        <form action={addAccountAction} className="grid gap-3 rounded-2xl bg-white p-5 sm:grid-cols-2">
          <h2 className="text-lg font-semibold sm:col-span-2">Add an account</h2>
          <div className="flex flex-col gap-2"><Label htmlFor="code">Code</Label><Input id="code" name="code" required placeholder="5100" /></div>
          <div className="flex flex-col gap-2"><Label htmlFor="name">Name</Label><Input id="name" name="name" required placeholder="Cement" /></div>
          <div className="flex flex-col gap-2">
            <Label htmlFor="accountType">Kind</Label>
            <select id="accountType" name="accountType" className="min-h-11 rounded-xl border border-[#e2d8c6] bg-white px-3">
              <option value="ASSET">What the firm holds</option>
              <option value="LIABILITY">What the firm owes</option>
              <option value="EQUITY">Owner’s money in the firm</option>
              <option value="INCOME">Money earned</option>
              <option value="EXPENSE">Money spent</option>
            </select>
          </div>
          <div className="flex flex-col gap-2">
            <Label htmlFor="normalBalance">Usual side</Label>
            <select id="normalBalance" name="normalBalance" className="min-h-11 rounded-xl border border-[#e2d8c6] bg-white px-3">
              <option value="DEBIT">Debit</option>
              <option value="CREDIT">Credit</option>
            </select>
          </div>
          <div className="sm:col-span-2"><Button type="submit" size="large">Save the account</Button></div>
        </form>
      ) : null}
    </OfficeFrame>
  );
}
