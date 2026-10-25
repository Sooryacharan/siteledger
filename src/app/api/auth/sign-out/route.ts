import { NextResponse } from "next/server";

import { SESSION_COOKIE, signOut } from "@/server/session";

export async function POST(request: Request) {
  const cookie = request.headers.get("cookie") ?? "";
  const match = cookie.match(new RegExp(`(?:^|;\\s*)${SESSION_COOKIE}=([^;]+)`));
  const token = match?.[1] ? decodeURIComponent(match[1]) : "";
  if (token) await signOut(token);
  const response = NextResponse.json({ ok: true });
  response.cookies.set(SESSION_COOKIE, "", { httpOnly: true, path: "/", maxAge: 0 });
  return response;
}
