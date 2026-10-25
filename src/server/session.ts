import { createHash, randomBytes } from "node:crypto";

import type { MembershipRole } from "@prisma/client";

import { appendAudit, ownerDb, withTenant } from "./db";
import { AccessError } from "./errors";
import type { TenantContext } from "./tenant";

const SESSION_DAYS = 14;
const TOKEN_MINUTES = 60;

export type ResolvedSession = {
  sessionToken: string;
  user: { id: string; email: string; name: string | null };
  memberships: Array<{
    organizationId: string;
    role: MembershipRole;
    partyId: string | null;
    organizationName: string;
  }>;
};

function sha256(value: string): string {
  return createHash("sha256").update(value).digest("hex");
}

function addMinutes(minutes: number): Date {
  return new Date(Date.now() + minutes * 60 * 1000);
}

function addDays(days: number): Date {
  return new Date(Date.now() + days * 24 * 60 * 60 * 1000);
}

export async function requestSignIn(email: string): Promise<{ token: string }> {
  const normalised = email.trim().toLowerCase();
  const user = await ownerDb.user.findUnique({ where: { email: normalised } });
  if (!user || user.deletedAt) {
    throw new AccessError("that email is not a member of a firm yet", "UNAUTHENTICATED");
  }
  const token = randomBytes(32).toString("hex");
  await ownerDb.verificationToken.create({
    data: {
      identifier: normalised,
      token: sha256(token),
      expires: addMinutes(TOKEN_MINUTES),
    },
  });
  return { token };
}

export async function confirmSignIn(input: {
  email: string;
  token: string;
  ipAddress: string | null;
  userAgent: string | null;
}): Promise<{ sessionToken: string; userId: string }> {
  const email = input.email.trim().toLowerCase();
  const row = await ownerDb.verificationToken.findUnique({
    where: { token: sha256(input.token) },
  });
  if (!row || row.identifier !== email || row.expires.getTime() < Date.now()) {
    throw new AccessError("that sign-in link has expired", "UNAUTHENTICATED");
  }
  const user = await ownerDb.user.findUnique({ where: { email } });
  if (!user || user.deletedAt) {
    throw new AccessError("that email is not a member of a firm yet", "UNAUTHENTICATED");
  }
  await ownerDb.verificationToken.delete({ where: { id: row.id } });
  const sessionToken = randomBytes(32).toString("hex");
  await ownerDb.session.create({
    data: {
      sessionToken: sha256(sessionToken),
      userId: user.id,
      expires: addDays(SESSION_DAYS),
    },
  });
  const memberships = await ownerDb.membership.findMany({
    where: { userId: user.id, isActive: true, deletedAt: null },
  });
  for (const membership of memberships) {
    const ctx: TenantContext = {
      organizationId: membership.organizationId,
      userId: user.id,
      role: membership.role,
      partyId: membership.partyId,
      ipAddress: input.ipAddress,
      userAgent: input.userAgent,
      deviceId: null,
      requestId: null,
    };
    await withTenant(ctx, async (tx) => {
      await appendAudit(tx, ctx, {
        action: "LOGIN",
        entityType: "USER",
        entityId: user.id,
        before: null,
        after: { email },
      });
    });
  }
  return { sessionToken, userId: user.id };
}

export async function resolveSession(sessionToken: string): Promise<ResolvedSession | null> {
  const session = await ownerDb.session.findUnique({
    where: { sessionToken: sha256(sessionToken) },
    include: { user: true },
  });
  if (!session || session.expires.getTime() < Date.now() || session.user.deletedAt) {
    return null;
  }
  const memberships = await ownerDb.membership.findMany({
    where: { userId: session.userId, isActive: true, deletedAt: null },
    include: { organization: true },
    orderBy: { createdAt: "asc" },
  });
  return {
    sessionToken,
    user: { id: session.user.id, email: session.user.email, name: session.user.name },
    memberships: memberships
      .filter((membership) => membership.organization.deletedAt == null)
      .map((membership) => ({
        organizationId: membership.organizationId,
        role: membership.role,
        partyId: membership.partyId,
        organizationName: membership.organization.displayName,
      })),
  };
}

export async function signOut(sessionToken: string): Promise<void> {
  await ownerDb.session.deleteMany({ where: { sessionToken: sha256(sessionToken) } });
}

export const SESSION_COOKIE = "siteledger_session";
export const ORG_COOKIE = "siteledger_org";
