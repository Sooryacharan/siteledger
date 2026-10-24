const checks = [
  {
    command: "npm run check",
    detail: "Validates the Prisma schema, runs the money tests, and parses every Mermaid diagram.",
  },
  {
    command: "npm test",
    detail: "Interest, EMI, GST, TDS, wages, stock, profit share, GSTIN, and the hash chain.",
  },
  {
    command: "npm run db:validate",
    detail: "prisma validate and prisma format --check. No database is required.",
  },
];

const built = [
  "Architecture, entity diagrams, and the folder map in docs/",
  "A Prisma schema of 112 models, including phases, towers, floors, the nine area fields, and facing",
  "Sales follow-ups, site visits, agreements, cancellations, transfers, and interest",
  "Vendor PAN, bank fingerprint, and phone keys for duplicate detection",
  "GSTIN checksum, CGST, SGST, and IGST on demands, invoices, and RA bills",
  "Contractor advances and recovery, and a reducing-balance EMI schedule",
  "Exception rules for round-figure payments and weekend payments",
  "Row-level security SQL for multi-tenant isolation, written and not yet applied",
];

export default function Home() {
  return (
    <main className="min-h-screen bg-[#f3efe4] text-[#1c1915]">
      <div className="mx-auto flex w-full max-w-3xl flex-col gap-10 px-5 py-12 sm:px-8 sm:py-16">
        <header className="flex flex-col gap-4">
          <p className="text-xs font-medium uppercase tracking-[0.18em] text-[#8a5a2a]">
            Step 1 of 5
          </p>
          <h1 className="font-[family-name:var(--font-geist-sans)] text-4xl font-semibold tracking-tight sm:text-5xl">
            SiteLedger
          </h1>
          <p className="max-w-2xl text-lg leading-relaxed text-[#3f3a33]">
            A project ledger for a developer: every rupee, every square foot, and every bag of
            material stays traceable. This step is the architecture and the data model. There is
            no login, no project screen, and no sample firm loaded yet.
          </p>
        </header>

        <section className="rounded-2xl border border-[#e2d8c6] bg-white p-5 sm:p-6">
          <h2 className="text-sm font-semibold uppercase tracking-[0.14em] text-[#6b645b]">
            What is in the repo
          </h2>
          <ul className="mt-4 flex flex-col gap-3">
            {built.map((item) => (
              <li key={item} className="flex gap-3 text-[15px] leading-6">
                <span className="mt-2 h-1.5 w-1.5 shrink-0 rounded-full bg-[#8a5a2a]" />
                <span>{item}</span>
              </li>
            ))}
          </ul>
        </section>

        <section>
          <h2 className="text-sm font-semibold uppercase tracking-[0.14em] text-[#6b645b]">
            How to test it
          </h2>
          <ol className="mt-4 flex flex-col gap-4">
            {checks.map((item, index) => (
              <li key={item.command} className="rounded-2xl bg-[#1c1915] p-4 text-[#f3efe4]">
                <p className="text-xs uppercase tracking-[0.16em] text-[#d7b089]">
                  Check {index + 1}
                </p>
                <code className="mt-2 block font-[family-name:var(--font-geist-mono)] text-sm">
                  {item.command}
                </code>
                <p className="mt-2 text-sm leading-6 text-[#e6dfd2]">{item.detail}</p>
              </li>
            ))}
          </ol>
          <p className="mt-4 text-sm leading-6 text-[#3f3a33]">
            Read <span className="font-medium">docs/ARCHITECTURE.md</span> for the rules and{" "}
            <span className="font-medium">docs/ER.md</span> for the diagrams. The product brief is
            stored verbatim in <span className="font-medium">docs/SPEC.md</span>. SQL under{" "}
            <span className="font-medium">prisma/sql</span> is reviewed here and applied only after
            a migration exists.
          </p>
        </section>

        <section className="border-t border-[#e2d8c6] pt-6 text-sm leading-6 text-[#3f3a33]">
          <p>
            Worked examples already locked by tests: ₹1,00,000 at 12% for 30 days is ₹986.30 of
            simple interest. A ₹10,00,000 loan at 10% for 12 months has an EMI of ₹87,915.89. Three
            paise of taxable value at 9% + 9% becomes 0 paise CGST and 1 paise SGST.
          </p>
          <p className="mt-3">
            The next step, when you ask for it, is auth, roles, and the audit-log middleware. Module
            screens stay after that.
          </p>
        </section>
      </div>
    </main>
  );
}
