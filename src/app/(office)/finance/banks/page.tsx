import Link from "next/link";

import { Button } from "@/components/ui/button";
import { Input } from "@/components/ui/input";
import { Label } from "@/components/ui/label";
import { OfficeFrame } from "@/components/office-frame";
import { canWriteFinance, listAccounts, listBanks } from "@/server/finance";
import { requireOffice } from "@/server/office";

import { addBankAction } from "../actions";

export const dynamic = "force-dynamic";

export default async function BanksPage({ searchParams }: { searchParams: { error?: string } }) {
  const office = await requireOffice();
  const [banks, accounts] = await Promise.all([listBanks(office.ctx), listAccounts(office.ctx)]);
  const assets = accounts.filter((account) => account.accountType === "ASSET" && !account.removed);
  const canWrite = canWriteFinance(office.ctx.role);
  return (
    <OfficeFrame person={office.session.user.name ?? office.session.user.email} firm={office.membership.organizationName} role={office.membership.role}>
      <Link href="/finance" className="text-sm text-[#8a5a2a]">Back to the books</Link>
      <h1 className="text-3xl font-semibold">Bank and cash</h1>
      <p className="max-w-2xl text-base leading-7 text-[#3f3a33]">
        Each real account points at one line in the chart. The balance is the posted journal, not a typed figure.
      </p>
      {searchParams.error ? <p className="rounded-2xl border border-[#e2b4a0] bg-white px-4 py-3 text-sm text-[#6b2d1a]">{searchParams.error}</p> : null}
      <ul className="flex flex-col gap-3">
        {banks.map((bank) => (
          <li key={bank.id} className="rounded-2xl bg-white p-4">
            <p className="text-lg font-semibold">{bank.displayName}</p>
            <p className="text-sm text-[#3f3a33]">
              {bank.isCash ? "Cash box" : `${bank.bankName ?? "Bank"} · ${bank.accountNumber ?? ""} · ${bank.ifsc ?? ""}`}
            </p>
            <p className="mt-1 font-medium">{bank.balanceLabel}</p>
          </li>
        ))}
      </ul>
      {canWrite && assets.length > 0 ? (
        <form action={addBankAction} className="grid gap-3 rounded-2xl bg-white p-5 sm:grid-cols-2">
          <h2 className="text-lg font-semibold sm:col-span-2">Add a bank or cash account</h2>
          <div className="flex flex-col gap-2 sm:col-span-2">
            <Label htmlFor="glAccountId">Chart account</Label>
            <select id="glAccountId" name="glAccountId" className="min-h-11 rounded-xl border border-[#e2d8c6] bg-white px-3">
              {assets.map((account) => (
                <option key={account.id} value={account.id}>{account.code} {account.name}</option>
              ))}
            </select>
          </div>
          <div className="flex flex-col gap-2"><Label htmlFor="displayName">Name people will see</Label><Input id="displayName" name="displayName" required placeholder="Site cash box" /></div>
          <div className="flex flex-col gap-2"><Label htmlFor="bankName">Bank</Label><Input id="bankName" name="bankName" placeholder="Example Cooperative Bank" /></div>
          <div className="flex flex-col gap-2"><Label htmlFor="accountNumber">Account number</Label><Input id="accountNumber" name="accountNumber" placeholder="00011000000011" /></div>
          <div className="flex flex-col gap-2"><Label htmlFor="ifsc">IFSC</Label><Input id="ifsc" name="ifsc" placeholder="REDB0000001" /></div>
          <label className="flex items-center gap-2 text-sm sm:col-span-2"><input type="checkbox" name="isCash" /> This is a cash box, not a bank</label>
          <div className="sm:col-span-2"><Button type="submit" size="large">Save the account</Button></div>
        </form>
      ) : null}
    </OfficeFrame>
  );
}
