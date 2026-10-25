import type { MembershipRole } from "@prisma/client";

import { AccessError } from "./errors";

/**
 * Default bands, in paise. A firm may replace the rows. The shape is the rule.
 *
 * - under ₹10,000: auto, and an approval row is still written with no actor
 * - ₹10,000 up to ₹1,00,000: one finance step
 * - ₹1,00,000 and above: finance, then owner
 *
 * ₹10,000 is 1,000,000 paise. ₹1,00,000 is 10,000,000 paise.
 */
export const DEFAULT_AUTO_MAX_PAISE = 999_999n;
export const DEFAULT_FINANCE_MAX_PAISE = 9_999_999n;
export const DEFAULT_OWNER_MIN_PAISE = 10_000_000n;

export type ApprovalBand = {
  minAmountPaise: bigint;
  maxAmountPaise: bigint | null;
  stepOrder: number;
  approverRole: MembershipRole | null;
  autoApprove: boolean;
};

export function defaultPaymentBands(): Array<ApprovalBand & { plainLanguage: string }> {
  return [
    {
      minAmountPaise: 0n,
      maxAmountPaise: DEFAULT_AUTO_MAX_PAISE,
      stepOrder: 1,
      approverRole: null,
      autoApprove: true,
      plainLanguage: "Under ₹10,000 the payment is approved, and the approval row has no person on it.",
    },
    {
      minAmountPaise: DEFAULT_AUTO_MAX_PAISE + 1n,
      maxAmountPaise: DEFAULT_FINANCE_MAX_PAISE,
      stepOrder: 1,
      approverRole: "FINANCE",
      autoApprove: false,
      plainLanguage: "From ₹10,000 up to ₹1,00,000, someone in finance approves.",
    },
    {
      minAmountPaise: DEFAULT_OWNER_MIN_PAISE,
      maxAmountPaise: null,
      stepOrder: 1,
      approverRole: "FINANCE",
      autoApprove: false,
      plainLanguage: "From ₹1,00,000, finance approves first.",
    },
    {
      minAmountPaise: DEFAULT_OWNER_MIN_PAISE,
      maxAmountPaise: null,
      stepOrder: 2,
      approverRole: "OWNER",
      autoApprove: false,
      plainLanguage: "From ₹1,00,000, an owner approves after finance. The person who asked cannot approve their own payment.",
    },
  ];
}

export function bandsForAmount(policies: ApprovalBand[], amountPaise: bigint): ApprovalBand[] {
  return policies
    .filter((policy) => {
      if (amountPaise < policy.minAmountPaise) return false;
      if (policy.maxAmountPaise != null && amountPaise > policy.maxAmountPaise) return false;
      return true;
    })
    .sort((a, b) => a.stepOrder - b.stepOrder);
}

export function assertEligibleChecker(input: {
  requesterId: string;
  actorId: string;
  actorRole: MembershipRole;
  requiredRole: MembershipRole;
  ownerIds: readonly string[];
}): void {
  if (input.actorId === input.requesterId) {
    throw new AccessError("the maker cannot be the checker", "APPROVAL");
  }

  if (input.actorRole === input.requiredRole || input.actorRole === "OWNER") {
    return;
  }

  const soleOwner =
    input.ownerIds.length === 1 && input.ownerIds[0] === input.requesterId;
  if (input.requiredRole === "OWNER" && soleOwner && input.actorRole === "FINANCE") {
    return;
  }

  throw new AccessError(
    `${input.actorRole} cannot approve a step that requires ${input.requiredRole}`,
    "APPROVAL",
  );
}
