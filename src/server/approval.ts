import type { ApprovalDecision, ApprovalEntity } from "@prisma/client";

import {
  assertEligibleChecker,
  bandsForAmount,
  type ApprovalBand,
} from "./approval-rules";
import { withTenant, type AppTx } from "./db";
import { AccessError } from "./errors";
import { assertCan } from "./permissions";
import type { TenantContext } from "./tenant";

async function loadBands(
  tx: AppTx,
  entityType: ApprovalEntity,
  amountPaise: bigint,
): Promise<ApprovalBand[]> {
  const policies = await tx.approvalPolicy.findMany({
    where: { entityType, isActive: true, deletedAt: null },
  });
  const bands = bandsForAmount(
    policies.map((policy) => ({
      minAmountPaise: policy.minAmountPaise,
      maxAmountPaise: policy.maxAmountPaise,
      stepOrder: policy.stepOrder,
      approverRole: policy.approverRole,
      autoApprove: policy.autoApprove,
    })),
    amountPaise,
  );
  if (bands.length === 0) {
    throw new AccessError("no approval band covers this amount", "APPROVAL");
  }
  return bands;
}

export async function submitApproval(
  ctx: TenantContext,
  input: { entityType: ApprovalEntity; entityId: string; amountPaise: bigint },
) {
  assertCan(ctx.role, "write");
  return withTenant(ctx, async (tx) => {
    const bands = await loadBands(tx, input.entityType, input.amountPaise);
    const pending = bands.find((band) => !band.autoApprove);
    const request = await tx.approvalRequest.create({
      data: {
        organizationId: ctx.organizationId,
        entityType: input.entityType,
        entityId: input.entityId,
        amountPaise: input.amountPaise,
        status: pending ? "PENDING" : "APPROVED",
        currentStep: pending ? pending.stepOrder : bands[bands.length - 1]!.stepOrder,
        requestedById: ctx.userId,
        completedAt: pending ? null : new Date(),
      },
    });
    for (const band of bands) {
      if (!band.autoApprove) break;
      await tx.approvalAction.create({
        data: {
          organizationId: ctx.organizationId,
          requestId: request.id,
          stepOrder: band.stepOrder,
          actorId: null,
          decision: "APPROVED",
          comment: "Under the auto-approval threshold",
        },
      });
    }
    return tx.approvalRequest.findUniqueOrThrow({
      where: { id: request.id },
      include: { actions: true },
    });
  });
}

export async function decideApproval(
  ctx: TenantContext,
  input: { requestId: string; decision: Extract<ApprovalDecision, "APPROVED" | "REJECTED">; comment?: string },
) {
  assertCan(ctx.role, "approve");
  return withTenant(ctx, async (tx) => {
    const request = await tx.approvalRequest.findUnique({ where: { id: input.requestId } });
    if (!request || request.status !== "PENDING" || request.amountPaise == null) {
      throw new AccessError("that request is not waiting for a decision", "APPROVAL");
    }
    const bands = await loadBands(tx, request.entityType, request.amountPaise);
    const step = bands.find((band) => band.stepOrder === request.currentStep && !band.autoApprove);
    if (!step?.approverRole) {
      throw new AccessError("this step has no checker", "APPROVAL");
    }
    const owners = await tx.membership.findMany({
      where: { role: "OWNER", isActive: true, deletedAt: null },
      select: { userId: true },
    });
    assertEligibleChecker({
      requesterId: request.requestedById,
      actorId: ctx.userId,
      actorRole: ctx.role,
      requiredRole: step.approverRole,
      ownerIds: owners.map((owner) => owner.userId),
    });
    await tx.approvalAction.create({
      data: {
        organizationId: ctx.organizationId,
        requestId: request.id,
        stepOrder: step.stepOrder,
        actorId: ctx.userId,
        decision: input.decision,
        comment: input.comment,
      },
    });
    if (input.decision === "REJECTED") {
      return tx.approvalRequest.update({
        where: { id: request.id },
        data: { status: "REJECTED", completedAt: new Date() },
      });
    }
    const next = bands.find((band) => band.stepOrder > step.stepOrder);
    if (!next) {
      return tx.approvalRequest.update({
        where: { id: request.id },
        data: { status: "APPROVED", completedAt: new Date() },
      });
    }
    return tx.approvalRequest.update({
      where: { id: request.id },
      data: { currentStep: next.stepOrder },
    });
  });
}
