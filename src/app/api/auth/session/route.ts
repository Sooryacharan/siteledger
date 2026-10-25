import { NextResponse } from "next/server";

import { SESSION_COOKIE, resolveSession } from "@/server/session";

export async function GET(request: Request) {
  const cookie = request.headers.get("cookie") ?? "";
  const match = cookie.match(new RegExp(`(?:^|;\\s*)${SESSION_COOKIE}=([^;]+)`));
  const token = match?.[1] ? decodeURIComponent(match[1]) : "";
  if (!token) return NextResponse.json({ user: null, memberships: [] });
  const session = await resolveSession(token);
  if (!session) return NextResponse.json({ user: null, memberships: [] });
  return NextResponse.json({ user: session.user, memberships: session.memberships });
}
