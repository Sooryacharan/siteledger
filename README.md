# SiteLedger

SiteLedger is a CRM and project-finance ledger for a real-estate developer. Step 1 is the architecture and the data model. Later steps add auth, the modules, and a local Docker stack.

The product brief is in [docs/SPEC.md](docs/SPEC.md). The design is in [docs/ARCHITECTURE.md](docs/ARCHITECTURE.md). The entity diagrams are in [docs/ER.md](docs/ER.md).

## What works now

- Next.js 14 (App Router), TypeScript, and Tailwind. The home page is a status page for this step.
- Prisma schema for every module in the brief: projects through dashboards, including phases, towers, floors, carpet / built-up / super built-up area, facing, follow-ups, site visits, agreements, cancellations, transfers, interest, vendor PAN / bank / phone, GSTIN, CGST / SGST / IGST, advances and recovery, EMI, and exception rules for round-figure and weekend payments.
- Multi-tenant row-level security in `prisma/sql/rls.sql`. It is not applied yet. PostgreSQL is not required to validate the schema.
- Tested formula code for interest, EMI, GST, TDS, attendance wages, weighted-average stock, BOQ allowance, profit share, GSTIN, and the hash chain.

## Run the status page

```bash
npm install
npm run dev
```

The dev server listens on port 43123. Open http://127.0.0.1:43123.

Copy `.env.example` to `.env` before `npm run check`. The sample URL points at a local Postgres that this step does not start.

## Test

```bash
npm run check
```

That command:

1. Runs `prisma validate` and `prisma format --check`.
2. Runs the formula, GSTIN, hash, and identity tests.
3. Parses every Mermaid diagram in `docs/`.
4. Checks that the schema still contains all 112 models and the fields named above.

`npm test` runs the tests on their own. No database is contacted.

## What is not in this step

Auth, role middleware, module screens, seed data, background jobs, and Docker. The proposed build order is in the architecture doc. Finance core comes before any module posts money, so those later screens do not invent a rupee figure.

## Stack pinned for this step

- Next.js 14.2.35
- Prisma 5.22.0
- PostgreSQL 16, when the SQL in `prisma/sql` is applied
- `decimal.js` 10.5.0 for half-up paise rounding
