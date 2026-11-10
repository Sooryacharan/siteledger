import { randomUUID } from "node:crypto";

import { withTenant } from "./db";
import { AccessError } from "./errors";
import { assertCan } from "./permissions";
import { nextPeriodStatus } from "./period-rules";
import type { TenantContext } from "./tenant";

/** A reopen needs a sentence, not a blank or a one-word tick. */
export function assertWrittenReason(reason: string): string {
  const trimmed = reason.trim();
  if (trimmed.length < 8) {
    throw new AccessError("write the reason in a sentence", "PERIOD");
  }
  return trimmed;
}

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
 * Owner-only. A one-owner firm may reopen, but only with a written reason.
 * The approval row, the period-lock event, and the audit log all keep that reason.
 * A payment above the automatic band still cannot be self-approved.
 */
export async function reopenPeriod(ctx: TenantContext, periodId: string, reason: string) {
  assertCan(ctx.role, "period.reopen");
  const written = assertWrittenReason(reason);
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
        comment: written,
      },
    });
    await tx.periodLockEvent.create({
      data: {
        organizationId: ctx.organizationId,
        periodId,
        action: "REOPEN",
        reason: written,
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
