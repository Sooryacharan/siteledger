import assert from "node:assert/strict";
import { describe, it } from "node:test";

import { AccessError } from "./errors";
import {
  DEFAULT_AUTO_MAX_PAISE,
  DEFAULT_FINANCE_MAX_PAISE,
  DEFAULT_OWNER_MIN_PAISE,
  assertEligibleChecker,
  bandsForAmount,
  type ApprovalBand,
} from "./approval-rules";

const bands: ApprovalBand[] = [
  {
    minAmountPaise: 0n,
    maxAmountPaise: DEFAULT_AUTO_MAX_PAISE,
    stepOrder: 1,
    approverRole: null,
    autoApprove: true,
  },
  {
    minAmountPaise: DEFAULT_AUTO_MAX_PAISE + 1n,
    maxAmountPaise: DEFAULT_FINANCE_MAX_PAISE,
    stepOrder: 1,
    approverRole: "FINANCE",
    autoApprove: false,
  },
  {
    minAmountPaise: DEFAULT_OWNER_MIN_PAISE,
    maxAmountPaise: null,
    stepOrder: 1,
    approverRole: "FINANCE",
    autoApprove: false,
  },
  {
    minAmountPaise: DEFAULT_OWNER_MIN_PAISE,
    maxAmountPaise: null,
    stepOrder: 2,
    approverRole: "OWNER",
    autoApprove: false,
  },
];

describe("approval bands", () => {
  it("auto-approves under ₹10,000 and asks finance from that amount", () => {
    assert.equal(bandsForAmount(bands, 500n)[0]?.autoApprove, true);
    assert.equal(bandsForAmount(bands, DEFAULT_AUTO_MAX_PAISE).length, 1);
    const finance = bandsForAmount(bands, 1_000_000n);
    assert.deepEqual(
      finance.map((band) => band.approverRole),
      ["FINANCE"],
    );
  });

  it("asks finance and then the owner from ₹1,00,000", () => {
    const steps = bandsForAmount(bands, 10_000_000n);
    assert.deepEqual(
      steps.map((band) => [band.stepOrder, band.approverRole]),
      [
        [1, "FINANCE"],
        [2, "OWNER"],
      ],
    );
  });

  it("refuses a maker who tries to check their own request", () => {
    assert.throws(
      () =>
        assertEligibleChecker({
          requesterId: "owner",
          actorId: "owner",
          actorRole: "OWNER",
          requiredRole: "FINANCE",
        }),
      (error: unknown) => error instanceof AccessError && error.code === "APPROVAL",
    );
  });

  it("lets the only owner approve their own large payment when they write a reason", () => {
    assert.throws(
      () =>
        assertEligibleChecker({
          requesterId: "owner",
          actorId: "owner",
          actorRole: "OWNER",
          requiredRole: "OWNER",
          amountPaise: 10_000_000n,
          ownerIds: ["owner"],
          writtenReason: "  ",
        }),
      (error: unknown) => error instanceof AccessError,
    );
    assert.doesNotThrow(() =>
      assertEligibleChecker({
        requesterId: "owner",
        actorId: "owner",
        actorRole: "OWNER",
        requiredRole: "OWNER",
        amountPaise: 10_000_000n,
        ownerIds: ["owner"],
        writtenReason: "The site needs this cement before the pour",
      }),
    );
    assert.throws(
      () =>
        assertEligibleChecker({
          requesterId: "owner",
          actorId: "owner",
          actorRole: "OWNER",
          requiredRole: "OWNER",
          amountPaise: 2_000_000n,
          ownerIds: ["owner"],
          writtenReason: "This is below one lakh",
        }),
      (error: unknown) => error instanceof AccessError && /maker cannot be the checker/.test(error.message),
    );
    assert.throws(
      () =>
        assertEligibleChecker({
          requesterId: "owner",
          actorId: "owner",
          actorRole: "OWNER",
          requiredRole: "OWNER",
          amountPaise: 10_000_000n,
          ownerIds: ["owner", "second"],
          writtenReason: "Another owner exists",
        }),
      (error: unknown) => error instanceof AccessError,
    );
  });

  it("requires the named role, so owner and finance cross-approve", () => {
    assert.doesNotThrow(() =>
      assertEligibleChecker({
        requesterId: "maker",
        actorId: "finance",
        actorRole: "FINANCE",
        requiredRole: "FINANCE",
      }),
    );
    assert.throws(
      () =>
        assertEligibleChecker({
          requesterId: "maker",
          actorId: "owner",
          actorRole: "OWNER",
          requiredRole: "FINANCE",
        }),
      (error: unknown) => error instanceof AccessError,
    );
    assert.throws(
      () =>
        assertEligibleChecker({
          requesterId: "owner",
          actorId: "finance",
          actorRole: "FINANCE",
          requiredRole: "OWNER",
        }),
      (error: unknown) => error instanceof AccessError,
    );
  });
});
