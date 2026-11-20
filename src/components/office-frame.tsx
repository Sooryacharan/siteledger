import Link from "next/link";

import { endSignIn } from "@/app/sign-in/actions";

export function OfficeFrame({
  person,
  firm,
  role,
  children,
}: {
  person: string;
  firm: string;
  role: string;
  children: React.ReactNode;
}) {
  return (
    <div className="min-h-screen bg-[#f3efe4] text-[#1c1915]">
      <header className="border-b border-[#e2d8c6] bg-[#f7f1e6]">
        <div className="mx-auto flex w-full max-w-5xl flex-wrap items-center justify-between gap-3 px-5 py-4">
          <div className="flex items-center gap-5">
            <Link href="/" className="text-sm font-semibold tracking-tight">
              SiteLedger
            </Link>
            <Link href="/projects" className="text-sm text-[#8a5a2a]">
              Projects
            </Link>
          </div>
          <div className="flex items-center gap-4 text-sm text-[#3f3a33]">
            <span>
              {person} · {firm} · {role.replace(/_/g, " ").toLowerCase()}
            </span>
            <form action={endSignIn}>
              <button type="submit" className="text-[#8a5a2a]">
                Sign out
              </button>
            </form>
          </div>
        </div>
      </header>
      <main className="mx-auto flex w-full max-w-5xl flex-col gap-8 px-5 py-8">{children}</main>
    </div>
  );
}
