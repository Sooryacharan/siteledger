import Link from "next/link";

import { OfficeFrame } from "@/components/office-frame";
import { cashPosition, canOpenFinance } from "@/server/finance";
import { requireOffice } from "@/server/office";

export const dynamic = "force-dynamic";

const LINKS = [
  { href: "/finance/accounts", title: "Chart of accounts", detail: "The names the books use for cash, capital, and costs." },
  { href: "/finance/journals", title: "Journal", detail: "Record money in and money out. Every entry must balance." },
  { href: "/finance/periods", title: "Accounting periods", detail: "Close a month, lock it, or reopen it with a written reason." },
  { href: "/finance/banks", title: "Bank and cash", detail: "The accounts that hold the firm’s money." },
  { href: "/finance/approvals", title: "Payments to approve", detail: "Small payments pass on their own. Larger ones need a second person." },
];

export default async function FinancePage() {
  const office = await requireOffice();
  if (!canOpenFinance(office.ctx.role)) {
    return (
      <OfficeFrame
        person={office.session.user.name ?? office.session.user.email}
        firm={office.membership.organizationName}
        role={office.membership.role}
      >
        <h1 className="text-3xl font-semibold">Books</h1>
        <p className="max-w-xl text-base leading-7 text-[#3f3a33]">
          The books are for the owner, the finance team, and the auditor. Your role can keep using projects.
        </p>
      </OfficeFrame>
    );
  }
  const cash = await cashPosition(office.ctx);
  return (
    <OfficeFrame
      person={office.session.user.name ?? office.session.user.email}
      firm={office.membership.organizationName}
      role={office.membership.role}
    >
      <div className="flex flex-col gap-2">
        <p className="text-xs font-medium uppercase tracking-[0.16em] text-[#8a5a2a]">Finance</p>
        <h1 className="text-3xl font-semibold tracking-tight">The books</h1>
        <p className="max-w-2xl text-base leading-7 text-[#3f3a33]">
          Money is stored in paise. A journal entry is saved only when the two sides match.
        </p>
      </div>
      <section className="rounded-2xl bg-[#1c1915] p-5 text-[#f3efe4]">
        <p className="text-xs uppercase tracking-[0.14em] text-[#d7b089]">Cash and bank together</p>
        <p className="mt-2 text-3xl font-semibold">{cash}</p>
        <p className="mt-2 text-sm leading-6 text-[#e6dfd2]">
          This is the posted balance on every cash and bank account. It is not a guess.
        </p>
      </section>
      <ul className="grid gap-3 sm:grid-cols-2">
        {LINKS.map((link) => (
          <li key={link.href}>
            <Link href={link.href} className="block min-h-28 rounded-2xl border border-[#e2d8c6] bg-white p-4 hover:border-[#8a5a2a]">
              <span className="text-lg font-semibold">{link.title}</span>
              <span className="mt-2 block text-sm leading-6 text-[#3f3a33]">{link.detail}</span>
            </Link>
          </li>
        ))}
      </ul>
    </OfficeFrame>
  );
}
