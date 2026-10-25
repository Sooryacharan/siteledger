import assert from "node:assert/strict";
import { describe, it } from "node:test";

import { computeAgreementShare, type ShareRule } from "./share";

const partnerA: ShareRule = {
  partnerPartyId: "partner-a",
  priority: 1,
  sharePercent: null,
  hurdleRatePercent: "12",
  fixedAmountPaise: null,
  isResidual: false,
  participatesInLoss: false,
  absorbsRounding: false,
};

const partnerB: ShareRule = {
  partnerPartyId: "partner-b",
  priority: 2,
  sharePercent: "60",
  hurdleRatePercent: null,
  fixedAmountPaise: null,
  isResidual: true,
  participatesInLoss: true,
  absorbsRounding: false,
};

const partnerC: ShareRule = {
  partnerPartyId: "partner-c",
  priority: 3,
  sharePercent: "40",
  hurdleRatePercent: null,
  fixedAmountPaise: null,
  isResidual: true,
  participatesInLoss: true,
  absorbsRounding: true,
};

describe("profit share", () => {
  it("pays a 12% hurdle and then the residual 60/40", () => {
    const entries = computeAgreementShare({
      basis: "PROFIT",
      profitPaise: 1_000_000_000n,
      rules: [partnerC, partnerA, partnerB],
      contributions: [{
        partnerPartyId: "partner-a",
        amountPaise: 5_000_000_000n,
        dayCount: 365,
      }],
    });
    assert.deepEqual(entries, [
      { partnerPartyId: "partner-a", entryType: "HURDLE", amountPaise: 600_000_000n },
      { partnerPartyId: "partner-b", entryType: "PROFIT", amountPaise: 240_000_000n },
      { partnerPartyId: "partner-c", entryType: "PROFIT", amountPaise: 160_000_000n },
    ]);
    const total = entries.reduce((sum, entry) => sum + entry.amountPaise, 0n);
    assert.equal(total, 1_000_000_000n);
  });

  it("gives the rounding paise to the partner marked as the absorber", () => {
    const entries = computeAgreementShare({
      basis: "REVENUE",
      profitPaise: 100n,
      rules: [
        { ...partnerB, sharePercent: "33.3333", hurdleRatePercent: null },
        { ...partnerC, sharePercent: "66.6667" },
      ],
      contributions: [],
    });
    const total = entries.reduce((sum, entry) => sum + entry.amountPaise, 0n);
    assert.equal(total, 100n);
    assert.equal(entries.find((entry) => entry.partnerPartyId === "partner-c")?.amountPaise, 67n);
  });

  it("splits a loss and does not pay a hurdle", () => {
    const entries = computeAgreementShare({
      basis: "PROFIT",
      profitPaise: -100n,
      rules: [partnerA, partnerB, partnerC],
      contributions: [{
        partnerPartyId: "partner-a",
        amountPaise: 5_000_000_000n,
        dayCount: 365,
      }],
    });
    assert.equal(entries.some((entry) => entry.entryType === "HURDLE"), false);
    const total = entries.reduce((sum, entry) => sum + entry.amountPaise, 0n);
    assert.equal(total, -100n);
  });

  it("rejects residual percents that do not sum to 100", () => {
    assert.throws(() => computeAgreementShare({
      basis: "PROFIT",
      profitPaise: 1000n,
      rules: [{ ...partnerB, sharePercent: "50" }, { ...partnerC, sharePercent: "40" }],
      contributions: [],
    }));
  });

  it("splits saleable area and refuses to mix it with a hurdle", () => {
    const entries = computeAgreementShare({
      basis: "SALEABLE_AREA",
      profitPaise: 1000n,
      rules: [],
      contributions: [],
      areas: [
        { partnerPartyId: "partner-b", areaSqft: "1" },
        { partnerPartyId: "partner-c", areaSqft: "2" },
      ],
    });
    const total = entries.reduce((sum, entry) => sum + entry.amountPaise, 0n);
    assert.equal(total, 1000n);
    assert.equal(entries.find((entry) => entry.partnerPartyId === "partner-c")?.amountPaise, 667n);
    assert.throws(() => computeAgreementShare({
      basis: "SALEABLE_AREA",
      profitPaise: 1000n,
      rules: [partnerA],
      contributions: [],
      areas: [{ partnerPartyId: "partner-a", areaSqft: "10" }],
    }));
  });
});
