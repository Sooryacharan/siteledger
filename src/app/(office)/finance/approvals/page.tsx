import Link from "next/link";

import { Button } from "@/components/ui/button";
import { Input } from "@/components/ui/input";
import { Label } from "@/components/ui/label";
import { OfficeFrame } from "@/components/office-frame";
import { canWriteFinance, listPaymentApprovals } from "@/server/finance";
import { requireOffice } from "@/server/office";

import { askApprovalAction, decideApprovalAction } from "../actions";

export const dynamic = "force-dynamic";

export default async function ApprovalsPage({ searchParams }: { searchParams: { error?: string } }) {
  const office = await requireOffice();
  const rows = await listPaymentApprovals(office.ctx);
  const canWrite = canWriteFinance(office.ctx.role);
  const canApprove = office.ctx.role === "OWNER" || office.ctx.role === "FINANCE";
  return (
    <OfficeFrame person={office.session.user.name ?? office.session.user.email} firm={office.membership.organizationName} role={office.membership.role}>
      <Link href="/finance" className="text-sm text-[#8a5a2a]">Back to the books</Link>
      <h1 className="text-3xl font-semibold">Payments to approve</h1>
      <p className="max-w-2xl text-base leading-7 text-[#3f3a33]">
        Under ₹10,000 the payment is recorded and approved with no second person. From ₹10,000, finance approves. From ₹1,00,000, finance approves and then an owner approves. The person who asked cannot approve it. If the firm has only one owner, that owner can approve their own payment of ₹1,00,000 or more only by writing the reason. The auditor can read that reason.
      </p>
      {searchParams.error ? <p className="rounded-2xl border border-[#e2b4a0] bg-white px-4 py-3 text-sm text-[#6b2d1a]">{searchParams.error}</p> : null}
      {canWrite ? (
        <form action={askApprovalAction} className="grid gap-3 rounded-2xl bg-white p-5 sm:grid-cols-[1fr_auto]">
          <div className="flex flex-col gap-2">
            <Label htmlFor="rupees">Amount in rupees</Label>
            <Input id="rupees" name="rupees" inputMode="decimal" required placeholder="100000" />
          </div>
          <Button type="submit" className="self-end">Ask for approval</Button>
        </form>
      ) : null}
      <ul className="flex flex-col gap-3">
        {rows.length === 0 ? <li className="rounded-2xl bg-white p-4">No payment approvals yet.</li> : null}
        {rows.map((row) => (
          <li key={row.id} className="rounded-2xl bg-white p-4">
            <p className="text-lg font-semibold">{row.amountLabel} · {row.status}</p>
            <p className="text-sm text-[#3f3a33]">Asked by {row.requestedBy}. Step {row.step}.</p>
            {row.reason ? <p className="mt-2 text-sm leading-6">Reason on file: {row.reason}</p> : null}
            {canApprove && row.status === "PENDING" ? (
              <form action={decideApprovalAction} className="mt-3 grid gap-2">
                <input type="hidden" name="requestId" value={row.id} />
                <Input name="reason" aria-label={`Reason for ${row.amountLabel}`} placeholder="Reason, required if you are the only owner approving your own large payment" />
                <div className="flex gap-2">
                  <Button type="submit" name="decision" value="APPROVED">Approve</Button>
                  <Button type="submit" name="decision" value="REJECTED" variant="outline">Send back</Button>
                </div>
              </form>
            ) : null}
          </li>
        ))}
      </ul>
    </OfficeFrame>
  );
}
