import assert from "node:assert/strict";
import { describe, it } from "node:test";

import {
  attendanceWagePaise,
  buildEmiSchedule,
  contractualEmiPaise,
  expectedMaterialQty,
  isExcessConsumption,
  issueValuePaise,
  receiveStock,
  simpleInterestPaise,
  splitGst,
  tdsPaise,
} from "./formulas";

const RUPEE = 100n;

describe("simple interest", () => {
  it("charges ₹986.30 on ₹1,00,000 at 12% for 30 days", () => {
    // 10,000,000 paise × 12 / 100 × 30 / 365 = 98,630.136... → 98,630 paise
    assert.equal(simpleInterestPaise(10_000_000n, "12", 30), 98630n);
  });

  it("returns zero when the principal or the day count is zero", () => {
    assert.equal(simpleInterestPaise(0n, "18", 10), 0n);
    assert.equal(simpleInterestPaise(5000n, "18", 0), 0n);
  });

  it("rejects a negative principal", () => {
    assert.throws(() => simpleInterestPaise(-1n, "12", 1));
  });
});

describe("EMI", () => {
  it("clears a zero-interest loan and puts the remainder on the last installment", () => {
    const schedule = buildEmiSchedule(100n, "0", 3);
    assert.equal(schedule.contractualEmiPaise, 33n);
    assert.deepEqual(
      schedule.lines.map((line) => line.principalPaise),
      [33n, 33n, 34n],
    );
    assert.equal(schedule.lines.at(-1)?.closingPrincipalPaise, 0n);
  });

  it("keeps a 10% loan of ₹10,00,000 for 12 months in balance", () => {
    const principal = 10_00_000n * RUPEE;
    const schedule = buildEmiSchedule(principal, "10", 12);
    assert.equal(schedule.contractualEmiPaise, 8791589n);
    assert.equal(schedule.lines.length, 12);
    assert.equal(schedule.lines.at(-1)?.closingPrincipalPaise, 0n);
    const principalSum = schedule.lines.reduce((sum, line) => sum + line.principalPaise, 0n);
    assert.equal(principalSum, principal);
    for (const line of schedule.lines) {
      assert.equal(line.emiPaise, line.principalPaise + line.interestPaise);
      assert.equal(
        line.closingPrincipalPaise,
        line.openingPrincipalPaise - line.principalPaise,
      );
    }
    for (const line of schedule.lines.slice(0, -1)) {
      assert.equal(line.emiPaise, schedule.contractualEmiPaise);
    }
    assert.equal(contractualEmiPaise(principal, "10", 12), 8791589n);
  });
});

describe("GST", () => {
  it("splits 18% intra-state tax into equal CGST and SGST", () => {
    const split = splitGst(10_000_000n, {
      cgstPercent: "9",
      sgstPercent: "9",
      igstPercent: "18",
      cessPercent: "0",
    }, "INTRA_STATE");
    assert.deepEqual(split, {
      cgstPaise: 900000n,
      sgstPaise: 900000n,
      igstPaise: 0n,
      cessPaise: 0n,
      gstPaise: 1800000n,
    });
  });

  it("gives a one-paise rounding residual to SGST", () => {
    const split = splitGst(3n, {
      cgstPercent: "9",
      sgstPercent: "9",
      igstPercent: "18",
      cessPercent: "0",
    }, "INTRA_STATE");
    assert.equal(split.cgstPaise, 0n);
    assert.equal(split.sgstPaise, 1n);
    assert.equal(split.gstPaise, 1n);
  });

  it("uses only IGST for an inter-state supply", () => {
    const split = splitGst(10_000_000n, {
      cgstPercent: "9",
      sgstPercent: "9",
      igstPercent: "18",
      cessPercent: "0",
    }, "INTER_STATE");
    assert.equal(split.igstPaise, 1800000n);
    assert.equal(split.cgstPaise, 0n);
    assert.equal(split.sgstPaise, 0n);
  });
});

describe("TDS", () => {
  it("charges the full bill once the year-to-date crosses the threshold", () => {
    assert.equal(tdsPaise({
      taxablePaise: 50_00n,
      ratePercent: "1",
      thresholdPaise: 100_00n,
      ytdTaxableBeforePaise: 40_00n,
    }), 0n);
    // 40 + 70 = 110, which is over 100. TDS is 1% of 70, not of the extra 10.
    assert.equal(tdsPaise({
      taxablePaise: 70_00n,
      ratePercent: "1",
      thresholdPaise: 100_00n,
      ytdTaxableBeforePaise: 40_00n,
    }), 70n);
  });
});

describe("attendance, stock, and BOQ", () => {
  it("pays half a day plus overtime at one eighth of the daily wage per hour", () => {
    assert.equal(attendanceWagePaise({
      dailyWagePaise: 80000n,
      status: "HALF_DAY",
      overtimeHours: "2",
    }), 60000n);
  });

  it("rejects overtime on an absent day", () => {
    assert.throws(() => attendanceWagePaise({
      dailyWagePaise: 80000n,
      status: "ABSENT",
      overtimeHours: "1",
    }));
  });

  it("recomputes the weighted average after a receipt and values an issue at that average", () => {
    const received = receiveStock({
      oldQty: "100",
      oldAverageRateRupees: "400",
      inQty: "50",
      inRateRupees: "420",
    });
    assert.equal(received.newQty, "150.0000");
    assert.equal(received.averageRateRupees, "406.666667");
    assert.equal(received.valuePaise, 2_100_000n);
    assert.equal(issueValuePaise("10", received.averageRateRupees), 406667n);
  });

  it("flags cement use above the BOQ allowance", () => {
    const expected = expectedMaterialQty({
      areaSqft: "1000",
      normQtyPerSqft: "0.4",
      wastageAllowancePercent: "2",
    });
    assert.equal(expected, "408.0000");
    assert.equal(isExcessConsumption("408.0000", expected), false);
    assert.equal(isExcessConsumption("408.0001", expected), true);
  });
});
