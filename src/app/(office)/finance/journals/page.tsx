import Link from "next/link";

import { Button } from "@/components/ui/button";
import { Input } from "@/components/ui/input";
import { Label } from "@/components/ui/label";
import { OfficeFrame } from "@/components/office-frame";
import { canWriteFinance, listAccounts, listJournals, listPeriods } from "@/server/finance";
import { requireOffice } from "@/server/office";

import { postJournalAction } from "../actions";

export const dynamic = "force-dynamic";

export default async function JournalsPage({ searchParams }: { searchParams: { error?: string } }) {
  const office = await requireOffice();
  const [journals, accounts, periods] = await Promise.all([
    listJournals(office.ctx),
    listAccounts(office.ctx),
    listPeriods(office.ctx),
  ]);
  const openPeriods = periods.filter((period) => period.status !== "LOCKED");
  const canWrite = canWriteFinance(office.ctx.role);
  return (
    <OfficeFrame person={office.session.user.name ?? office.session.user.email} firm={office.membership.organizationName} role={office.membership.role}>
      <Link href="/finance" className="text-sm text-[#8a5a2a]">Back to the books</Link>
      <h1 className="text-3xl font-semibold">Journal</h1>
      <p className="max-w-2xl text-base leading-7 text-[#3f3a33]">
        Each entry has two sides. The money in must equal the money out, to the paise. A locked month refuses a new entry.
      </p>
      {searchParams.error ? <p className="rounded-2xl border border-[#e2b4a0] bg-white px-4 py-3 text-sm text-[#6b2d1a]">{searchParams.error}</p> : null}
      {canWrite && openPeriods.length > 0 && accounts.length > 0 ? (
        <form action={postJournalAction} className="grid gap-3 rounded-2xl bg-white p-5">
          <h2 className="text-lg font-semibold">Record an entry</h2>
          <div className="grid gap-3 sm:grid-cols-3">
            <div className="flex flex-col gap-2">
              <Label htmlFor="periodId">Month</Label>
              <select id="periodId" name="periodId" className="min-h-11 rounded-xl border border-[#e2d8c6] bg-white px-3">
                {openPeriods.map((period) => (
                  <option key={period.id} value={period.id}>{period.name}</option>
                ))}
              </select>
            </div>
            <div className="flex flex-col gap-2">
              <Label htmlFor="entryDate">Date</Label>
              <Input id="entryDate" name="entryDate" type="date" required defaultValue={openPeriods[0]?.startsOn} />
            </div>
            <div className="flex flex-col gap-2">
              <Label htmlFor="narration">What this is</Label>
              <Input id="narration" name="narration" required placeholder="Capital brought in" />
            </div>
          </div>
          {[1, 2].map((index) => (
            <div key={index} className="grid gap-3 sm:grid-cols-3">
              <select name={`account${index}`} aria-label={`Account ${index}`} className="min-h-11 rounded-xl border border-[#e2d8c6] bg-white px-3" required>
                {accounts.map((account) => (
                  <option key={account.id} value={account.id}>{account.code} {account.name}</option>
                ))}
              </select>
              <select name={`side${index}`} aria-label={`Side ${index}`} className="min-h-11 rounded-xl border border-[#e2d8c6] bg-white px-3" defaultValue={index === 1 ? "debit" : "credit"}>
                <option value="debit">Money in (debit)</option>
                <option value="credit">Money out (credit)</option>
              </select>
              <Input name={`rupees${index}`} inputMode="decimal" aria-label={`Rupees ${index}`} placeholder="Amount in rupees" required />
            </div>
          ))}
          <div className="grid gap-3 sm:grid-cols-3">
            <select name="account3" aria-label="Account 3" className="min-h-11 rounded-xl border border-[#e2d8c6] bg-white px-3">
              <option value="">No third line</option>
              {accounts.map((account) => (
                <option key={account.id} value={account.id}>{account.code} {account.name}</option>
              ))}
            </select>
            <select name="side3" aria-label="Side 3" className="min-h-11 rounded-xl border border-[#e2d8c6] bg-white px-3" defaultValue="credit">
              <option value="debit">Money in (debit)</option>
              <option value="credit">Money out (credit)</option>
            </select>
            <Input name="rupees3" inputMode="decimal" aria-label="Rupees 3" placeholder="Optional third amount" />
          </div>
          <Button type="submit" size="large">Post the entry</Button>
        </form>
      ) : null}
      <section className="flex flex-col gap-3">
        {journals.length === 0 ? <p className="rounded-2xl bg-white p-4">No posted entries yet.</p> : null}
        {journals.map((entry) => (
          <article key={entry.id} className="rounded-2xl bg-white p-4">
            <h2 className="font-semibold">{entry.entryNumber} · {entry.entryDate} · {entry.totalLabel}</h2>
            <p className="text-sm text-[#3f3a33]">{entry.narration}</p>
            <ul className="mt-2 text-sm leading-6">
              {entry.lines.map((line) => (
                <li key={`${entry.id}-${line.account}-${line.debit}-${line.credit}`}>
                  {line.account}: {line.debit ? `${line.debit} in` : `${line.credit} out`}
                </li>
              ))}
            </ul>
          </article>
        ))}
      </section>
    </OfficeFrame>
  );
}
