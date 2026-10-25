import Link from "next/link";

import { finishSignIn, startSignIn } from "./actions";

export const dynamic = "force-dynamic";

export default function SignInPage({
  searchParams,
}: {
  searchParams: { email?: string; token?: string; sent?: string; error?: string };
}) {
  const email = searchParams.email ?? "";
  const token = searchParams.token ?? "";
  return (
    <main className="min-h-screen bg-[#f3efe4] text-[#1c1915]">
      <div className="mx-auto flex w-full max-w-lg flex-col gap-8 px-5 py-12 sm:px-8 sm:py-16">
        <header className="flex flex-col gap-3">
          <p className="text-xs font-medium uppercase tracking-[0.18em] text-[#8a5a2a]">Sign in</p>
          <h1 className="text-4xl font-semibold tracking-tight">SiteLedger</h1>
          <p className="text-base leading-7 text-[#3f3a33]">
            Use the email on your firm membership. There is no password in this step. A one-time
            token opens the session.
          </p>
        </header>

        {searchParams.error ? (
          <p className="rounded-2xl border border-[#e2b4a0] bg-white px-4 py-3 text-sm leading-6 text-[#6b2d1a]">
            {searchParams.error}
          </p>
        ) : null}

        <form action={startSignIn} className="flex flex-col gap-3 rounded-2xl bg-white p-5">
          <label className="text-sm font-medium" htmlFor="email">
            Email
          </label>
          <input
            id="email"
            name="email"
            type="email"
            required
            defaultValue={email}
            autoComplete="username"
            className="rounded-xl border border-[#e2d8c6] px-3 py-3 text-base"
          />
          <button
            type="submit"
            className="rounded-xl bg-[#1c1915] px-4 py-3 text-sm font-medium text-[#f3efe4]"
          >
            Email me a sign-in token
          </button>
        </form>

        {searchParams.sent === "1" ? (
          <p className="text-sm leading-6 text-[#3f3a33]">
            If this machine is not set to show tokens, the token stays in the sign-in table until
            you confirm it.
          </p>
        ) : null}

        {token ? (
          <form action={finishSignIn} className="flex flex-col gap-3 rounded-2xl bg-white p-5">
            <p className="text-sm leading-6 text-[#3f3a33]">
              Local machines show the token here. Paste it if you already have one.
            </p>
            <input type="hidden" name="email" value={email} />
            <label className="text-sm font-medium" htmlFor="token">
              Token
            </label>
            <input
              id="token"
              name="token"
              required
              defaultValue={token}
              className="rounded-xl border border-[#e2d8c6] px-3 py-3 font-[family-name:var(--font-geist-mono)] text-xs"
            />
            <button
              type="submit"
              className="rounded-xl bg-[#1c1915] px-4 py-3 text-sm font-medium text-[#f3efe4]"
            >
              Open the session
            </button>
          </form>
        ) : null}

        <Link href="/" className="text-sm text-[#8a5a2a]">
          Back to the status page
        </Link>
      </div>
    </main>
  );
}
