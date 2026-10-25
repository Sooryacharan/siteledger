# SiteLedger

SiteLedger is a CRM and project-finance ledger for a real-estate developer. Step 3 adds auth, roles, and the audit log on top of the step 1 data model. Module screens come later.

The product brief is in [docs/SPEC.md](docs/SPEC.md). The design is in [docs/ARCHITECTURE.md](docs/ARCHITECTURE.md). The entity diagrams are in [docs/ER.md](docs/ER.md).

## What works now

- Next.js 14 (App Router), TypeScript, and Tailwind. The home page is a status page for this step.
- Prisma schema for every module in the brief: projects through dashboards, including phases, towers, floors, carpet / built-up / super built-up area, facing, follow-ups, site visits, agreements, cancellations, transfers, interest, vendor PAN / bank / phone, GSTIN, CGST / SGST / IGST, advances and recovery, EMI, and exception rules for round-figure and weekend payments.
- Eight roles and a permission matrix. Sign-in is a one-time email token. There is no password.
- Row-level security, immutability, checks, and views from `prisma/sql`, applied by `prisma/migrations`.
- An append-only audit log, maker-checker amount bands, owner-only period reopen, and journal hash-chain helpers.
- Tested formula code for interest, EMI, GST, TDS, attendance wages, weighted-average stock, BOQ allowance, profit share, GSTIN, and the hash chain.
- Seed data for two fictional firms, Red Earth Developers and Blue Basin Estates.

## Run the status page

```bash
npm install
cp .env.example .env
docker compose up -d --wait
npm run db:migrate
npm run db:seed
npm run dev
```

The dev server listens on port 43123. Open http://127.0.0.1:43123.

Sign in as `dev.krishnan@red-earth.example` (finance at Red Earth) or `harish.gowda@red-earth.example` (auditor). On a local machine the sign-in page shows the one-time token. That display is `AUTH_EXPOSE_SIGNIN_TOKEN` in `.env`, and it should be off outside this machine.

`.env` is gitignored. The database passwords in `.env.example` and `docker-compose.yml` are local placeholders.

## Test

```bash
npm run check
npm run test:integration
```

`npm run check` does not need Postgres. It:

1. Runs `prisma validate` and `prisma format --check`.
2. Runs the formula, GSTIN, hash, identity, permission, approval, and period tests.
3. Parses every Mermaid diagram in `docs/`.
4. Checks that the schema still contains all 112 models and the fields named in the architecture.

`npm run test:integration` needs the compose Postgres from the commands above. It checks that:

- an auditor cannot change a party, and can record an export
- a finance user in one firm cannot read the other firm's party
- a sales user sees only an assigned project's lead, and a vendor sees only their own party
- the application refuses a hard delete, and Postgres denies `DELETE` to `siteledger_app`
- an audit row cannot be updated or deleted, including by the table owner
- a journal narration changed under a disabled immutability trigger fails the hash check
- a payment under ₹10,000 is auto-approved with no person on the action, and the maker cannot approve a larger one
- finance cannot reopen a locked period, and an owner can, with the reopen logged

## What is not in this step

Module screens, background jobs, file storage, and a deployment guide. The proposed build order is in the architecture doc. Finance core comes before any module posts money.

## Stack pinned for this step

- Next.js 14.2.35
- Prisma 5.22.0
- PostgreSQL 16, via `docker compose`
- `decimal.js` 10.5.0 for half-up paise rounding
