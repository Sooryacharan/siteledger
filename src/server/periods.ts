import { randomUUID } from "node:crypto";

import { withTenant } from "./db";
import { assertCan } from "./permissions";
import { nextPeriodStatus } from "./period-rules";
import type { TenantContext } from "./tenant";

export async function softClosePeriod(ctx: TenantContext, periodId: string, reason: string) {
  assertCan(ctx.role, "write");
  return withTenant(ctx, async (tx) => {
    const period = await tx.accountingPeriod.findUniqueOrThrow({ where: { id: periodId } });
    const status = nextPeriodStatus(period.status, "SOFT_CLOSE", ctx.role);
    await tx.periodLockEvent.create({
      data: {
        organizationId: ctx.organizationId,
        periodId,
        action: "SOFT_CLOSE",
        reason,
        actorId: ctx.userId,
      },
    });
    return tx.accountingPeriod.update({ where: { id: periodId }, data: { status } });
  });
}

export async function lockPeriod(ctx: TenantContext, periodId: string, reason: string) {
  assertCan(ctx.role, "write");
  return withTenant(ctx, async (tx) => {
    const period = await tx.accountingPeriod.findUniqueOrThrow({ where: { id: periodId } });
    const status = nextPeriodStatus(period.status, "LOCK", ctx.role);
    await tx.periodLockEvent.create({
      data: {
        organizationId: ctx.organizationId,
        periodId,
        action: "LOCK",
        reason,
        actorId: ctx.userId,
      },
    });
    return tx.accountingPeriod.update({
      where: { id: periodId },
      data: { status, lockedAt: new Date(), lockedById: ctx.userId },
    });
  });
}

/**
 * Owner-only. The same owner may request and approve, because a one-owner firm
 * still has to reopen a period, and the database requires an approval row.
 * A payment above the auto threshold still cannot be self-approved.
 */
export async function reopenPeriod(ctx: TenantContext, periodId: string, reason: string) {
  assertCan(ctx.role, "period.reopen");
  return withTenant(ctx, async (tx) => {
    const period = await tx.accountingPeriod.findUniqueOrThrow({ where: { id: periodId } });
    const status = nextPeriodStatus(period.status, "REOPEN", ctx.role);
    const requestId = randomUUID();
    await tx.approvalRequest.create({
      data: {
        id: requestId,
        organizationId: ctx.organizationId,
        entityType: "PERIOD_REOPEN",
        entityId: periodId,
        status: "APPROVED",
        currentStep: 1,
        requestedById: ctx.userId,
        completedAt: new Date(),
      },
    });
    await tx.approvalAction.create({
      data: {
        organizationId: ctx.organizationId,
        requestId,
        stepOrder: 1,
        actorId: ctx.userId,
        decision: "APPROVED",
        comment: reason,
      },
    });
    await tx.periodLockEvent.create({
      data: {
        organizationId: ctx.organizationId,
        periodId,
        action: "REOPEN",
        reason,
        actorId: ctx.userId,
        approvalRequestId: requestId,
      },
    });
    return tx.accountingPeriod.update({
      where: { id: periodId },
      data: { status, lockedAt: null, lockedById: null },
    });
  });
}
