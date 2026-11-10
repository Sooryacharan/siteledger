import { randomUUID } from "node:crypto";

import { cookies, headers } from "next/headers";
import { redirect } from "next/navigation";

import type { MembershipRole } from "@prisma/client";

import { ORG_COOKIE, SESSION_COOKIE, resolveSession, type ResolvedSession } from "./session";
import type { TenantContext } from "./tenant";

export type OfficeSession = {
  session: ResolvedSession;
  membership: ResolvedSession["memberships"][number];
  ctx: TenantContext;
};

export async function requireOffice(): Promise<OfficeSession> {
  const token = cookies().get(SESSION_COOKIE)?.value;
  if (!token) redirect("/sign-in");
  const session = await resolveSession(token);
  if (!session) redirect("/sign-in");
  const requested = cookies().get(ORG_COOKIE)?.value;
  const membership =
    session.memberships.find((item) => item.organizationId === requested) ?? session.memberships[0];
  if (!membership) redirect("/sign-in?error=That%20account%20is%20not%20on%20a%20firm%20yet");
  if (membership.role === "VENDOR" || membership.role === "CUSTOMER") {
    redirect("/?notice=portal");
  }
  const headerList = headers();
  const forwarded = headerList.get("x-forwarded-for");
  return {
    session,
    membership,
    ctx: {
      organizationId: membership.organizationId,
      userId: session.user.id,
      role: membership.role,
      partyId: membership.partyId,
      ipAddress: forwarded?.split(",")[0]?.trim() || headerList.get("x-real-ip"),
      userAgent: headerList.get("user-agent"),
      deviceId: null,
      requestId: randomUUID(),
    },
  };
}

export function isPortal(role: MembershipRole): boolean {
  return role === "VENDOR" || role === "CUSTOMER";
}
