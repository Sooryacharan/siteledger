import { NextResponse } from "next/server";

import { AccessError } from "@/server/errors";
import { SESSION_COOKIE, confirmSignIn, resolveSession } from "@/server/session";

export async function POST(request: Request) {
  const body = (await request.json().catch(() => null)) as { email?: string; token?: string } | null;
  try {
    const signedIn = await confirmSignIn({
      email: body?.email ?? "",
      token: body?.token ?? "",
      ipAddress: request.headers.get("x-forwarded-for")?.split(",")[0]?.trim() ?? null,
      userAgent: request.headers.get("user-agent"),
    });
    const session = await resolveSession(signedIn.sessionToken);
    const response = NextResponse.json({
      ok: true,
      user: session?.user ?? null,
      memberships: session?.memberships ?? [],
    });
    response.cookies.set(SESSION_COOKIE, signedIn.sessionToken, {
      httpOnly: true,
      sameSite: "lax",
      path: "/",
      secure: process.env.NODE_ENV === "production",
      maxAge: 60 * 60 * 24 * 14,
    });
    return response;
  } catch (error) {
    const message = error instanceof Error ? error.message : "Sign-in failed";
    const status = error instanceof AccessError ? 401 : 400;
    return NextResponse.json({ error: message }, { status });
  }
}
