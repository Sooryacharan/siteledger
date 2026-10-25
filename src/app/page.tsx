import Link from "next/link";
import { cookies } from "next/headers";

import { ORG_COOKIE, SESSION_COOKIE, resolveSession } from "@/server/session";

import { endSignIn } from "./sign-in/actions";

export const dynamic = "force-dynamic";

const checks = [
  {
    command: "npm run check",
    detail: "Validates the Prisma schema, runs the formula and permission tests, and parses every Mermaid diagram. No database.",
  },
  {
    command: "docker compose up -d --wait && npm run db:migrate && npm run db:seed",
    detail: "Starts PostgreSQL 16, applies the schema and the row-level security scripts, and loads the example firms.",
  },
  {
    command: "npm run test:integration",
    detail: "Proves the auditor cannot write, another firm is invisible, deletes are refused, audit rows cannot change, and a tampered journal hash is detected.",
  },
];

const built = [
  "Eight roles, with a permission matrix and a membership on each firm",
  "Row-level security from prisma/sql, applied by a migration, including project and portal scope",
  "An audit row on every application write: who, what, when, old value, new value, IP, and device",
  "No hard delete on the application role. Append-only tables reject updates, including from the database owner",
  "Maker-checker bands by amount and role. The maker cannot approve their own request",
  "Locked periods. Only an owner can reopen one, and that reopen is logged",
  "Hash-chain helpers for journal entries, with a check that spots a changed payload",
];

export default async function Home() {
  const token = cookies().get(SESSION_COOKIE)?.value;
  const session = token ? await resolveSession(token) : null;
  const organizationId = cookies().get(ORG_COOKIE)?.value;
  const membership =
    session?.memberships.find((item) => item.organizationId === organizationId) ??
    session?.memberships[0];

  return (
    <main className="min-h-screen bg-[#f3efe4] text-[#1c1915]">
      <div className="mx-auto flex w-full max-w-3xl flex-col gap-10 px-5 py-12 sm:px-8 sm:py-16">
        <header className="flex flex-col gap-4">
          <p className="text-xs font-medium uppercase tracking-[0.18em] text-[#8a5a2a]">
            Step 3 of 5
          </p>
          <h1 className="font-[family-name:var(--font-geist-sans)] text-4xl font-semibold tracking-tight sm:text-5xl">
            SiteLedger
          </h1>
          <p className="max-w-2xl text-lg leading-relaxed text-[#3f3a33]">
            Auth, roles, and the audit log are in place. Module screens are not. The example firms
            are Red Earth Developers and Blue Basin Estates. The people and the GSTINs are made up.
          </p>
        </header>

        <section className="rounded-2xl border border-[#e2d8c6] bg-white p-5 sm:p-6">
          <h2 className="text-sm font-semibold uppercase tracking-[0.14em] text-[#6b645b]">
            This session
          </h2>
          {session && membership ? (
            <div className="mt-4 flex flex-col gap-3 text-[15px] leading-6">
              <p>
                {session.user.name ?? session.user.email} is signed in to {membership.organizationName}{" "}
                as {membership.role.replace(/_/g, " ").toLowerCase()}.
              </p>
              <form action={endSignIn}>
                <button type="submit" className="text-sm font-medium text-[#8a5a2a]">
                  Sign out
                </button>
              </form>
            </div>
          ) : (
            <p className="mt-4 text-[15px] leading-6">
              Nobody is signed in.{" "}
              <Link href="/sign-in" className="font-medium text-[#8a5a2a]">
                Sign in
              </Link>{" "}
              with a seeded email such as dev.krishnan@red-earth.example.
            </p>
          )}
        </section>

        <section className="rounded-2xl border border-[#e2d8c6] bg-white p-5 sm:p-6">
          <h2 className="text-sm font-semibold uppercase tracking-[0.14em] text-[#6b645b]">
            What this step adds
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
            Copy <span className="font-medium">.env.example</span> to{" "}
            <span className="font-medium">.env</span> first. The sample URLs point at the Postgres
            service in docker-compose.yml. Read{" "}
            <span className="font-medium">docs/ARCHITECTURE.md</span> for the confirmed rules.
          </p>
        </section>

        <section className="border-t border-[#e2d8c6] pt-6 text-sm leading-6 text-[#3f3a33]">
          <p>
            The next step, when you ask for it, is the finance core: chart of accounts, journals,
            periods, and bank accounts. Sales, vendors, and the other modules stay after that.
          </p>
        </section>
      </div>
    </main>
  );
}
