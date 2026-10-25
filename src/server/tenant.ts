import { AsyncLocalStorage } from "node:async_hooks";

import type { MembershipRole, Prisma } from "@prisma/client";

export type TenantContext = {
  organizationId: string;
  userId: string;
  role: MembershipRole;
  partyId: string | null;
  ipAddress: string | null;
  userAgent: string | null;
  deviceId: string | null;
  requestId: string | null;
};

export type TenantStore = {
  ctx: TenantContext;
  tx: Prisma.TransactionClient;
  inAudit: boolean;
  actionOverride: import("@prisma/client").AuditAction | null;
};

export const tenantStore = new AsyncLocalStorage<TenantStore>();

/** Sets the four session values row-level security reads. Local to the transaction. */
export async function applySession(
  tx: { $queryRaw: Prisma.TransactionClient["$queryRaw"] },
  ctx: TenantContext,
): Promise<void> {
  await tx.$queryRaw`SELECT set_config('app.organization_id', ${ctx.organizationId}, true)`;
  await tx.$queryRaw`SELECT set_config('app.user_id', ${ctx.userId}, true)`;
  await tx.$queryRaw`SELECT set_config('app.role', ${ctx.role}, true)`;
  await tx.$queryRaw`SELECT set_config('app.party_id', ${ctx.partyId ?? ""}, true)`;
}
