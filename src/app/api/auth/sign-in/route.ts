import { NextResponse } from "next/server";

import { AccessError } from "@/server/errors";
import { requestSignIn } from "@/server/session";

export async function POST(request: Request) {
  const body = (await request.json().catch(() => null)) as { email?: string } | null;
  try {
    const { token } = await requestSignIn(body?.email ?? "");
    if (process.env.AUTH_EXPOSE_SIGNIN_TOKEN === "true") {
      return NextResponse.json({ ok: true, token });
    }
    return NextResponse.json({ ok: true });
  } catch (error) {
    const message = error instanceof Error ? error.message : "Sign-in failed";
    const status = error instanceof AccessError ? 401 : 400;
    return NextResponse.json({ error: message }, { status });
  }
}
