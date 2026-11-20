import Link from "next/link";

import { Button } from "@/components/ui/button";
import { Input } from "@/components/ui/input";
import { Label } from "@/components/ui/label";
import { OfficeFrame } from "@/components/office-frame";
import { canWriteFinance, listPeriods } from "@/server/finance";
import { requireOffice } from "@/server/office";

import { movePeriodAction, openPeriodAction } from "../actions";

export const dynamic = "force-dynamic";

const STATUS: Record<string, string> = {
  OPEN: "Open",
  SOFT_CLOSED: "Soft closed",
  LOCKED: "Locked",
};

export default async function PeriodsPage({ searchParams }: { searchParams: { error?: string } }) {
  const office = await requireOffice();
  const periods = await listPeriods(office.ctx);
  const canWrite = canWriteFinance(office.ctx.role);
  const isOwner = office.ctx.role === "OWNER";
  return (
    <OfficeFrame person={office.session.user.name ?? office.session.user.email} firm={office.membership.organizationName} role={office.membership.role}>
      <Link href="/finance" className="text-sm text-[#8a5a2a]">Back to the books</Link>
      <h1 className="text-3xl font-semibold">Accounting periods</h1>
      <p className="max-w-2xl text-base leading-7 text-[#3f3a33]">
        An open month still takes entries. A locked month does not. Only the owner can reopen a locked month, and they must write why.
      </p>
      {searchParams.error ? <p className="rounded-2xl border border-[#e2b4a0] bg-white px-4 py-3 text-sm text-[#6b2d1a]">{searchParams.error}</p> : null}
      <ul className="flex flex-col gap-3">
        {periods.map((period) => (
          <li key={period.id} className="rounded-2xl bg-white p-4">
            <p className="font-semibold">{period.name} · {STATUS[period.status] ?? period.status}</p>
            <p className="text-sm text-[#3f3a33]">{period.startsOn} to {period.endsOn}</p>
            {canWrite && period.status === "OPEN" ? (
              <form action={movePeriodAction} className="mt-3 flex flex-wrap gap-2">
                <input type="hidden" name="periodId" value={period.id} />
                <input type="hidden" name="move" value="soft-close" />
                <Button type="submit" variant="outline">Soft-close this month</Button>
              </form>
            ) : null}
            {canWrite && period.status === "SOFT_CLOSED" ? (
              <form action={movePeriodAction} className="mt-3 flex flex-wrap gap-2">
                <input type="hidden" name="periodId" value={period.id} />
                <input type="hidden" name="move" value="lock" />
                <Button type="submit" variant="outline">Lock this month</Button>
              </form>
            ) : null}
            {isOwner && period.status === "LOCKED" ? (
              <form action={movePeriodAction} className="mt-3 grid gap-2 sm:grid-cols-[1fr_auto]">
                <input type="hidden" name="periodId" value={period.id} />
                <input type="hidden" name="move" value="reopen" />
                <Input name="reason" required placeholder="Why this month should open again" aria-label={`Reason to reopen ${period.name}`} />
                <Button type="submit">Reopen</Button>
              </form>
            ) : null}
          </li>
        ))}
      </ul>
      {canWrite ? (
        <form action={openPeriodAction} className="grid gap-3 rounded-2xl bg-white p-5 sm:grid-cols-2">
          <h2 className="text-lg font-semibold sm:col-span-2">Open another month</h2>
          <div className="flex flex-col gap-2"><Label htmlFor="name">Name</Label><Input id="name" name="name" required placeholder="May 2026" /></div>
          <div className="flex flex-col gap-2"><Label htmlFor="fiscalYearName">Year</Label><Input id="fiscalYearName" name="fiscalYearName" defaultValue="FY 2026-27" /></div>
          <div className="flex flex-col gap-2"><Label htmlFor="startsOn">Starts</Label><Input id="startsOn" name="startsOn" type="date" required /></div>
          <div className="flex flex-col gap-2"><Label htmlFor="endsOn">Ends</Label><Input id="endsOn" name="endsOn" type="date" required /></div>
          <div className="sm:col-span-2"><Button type="submit" size="large">Open the month</Button></div>
        </form>
      ) : null}
    </OfficeFrame>
  );
}
