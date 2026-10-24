import Decimal from "decimal.js";

import { halfUpPaise, paiseDecimal, parsePercent } from "./rounding";

/**
 * Simple interest, actual/365.
 * amount = round_half_up(principalPaise × annualRatePercent / 100 × dayCount / 365)
 * Compound interest is not implemented. A rule with compound = true must be rejected
 * by the caller before this function is used.
 */
export function simpleInterestPaise(
  principalPaise: bigint,
  annualRatePercent: string,
  dayCount: number,
): bigint {
  if (principalPaise < 0n) {
    throw new Error("principalPaise cannot be negative");
  }
  if (!Number.isInteger(dayCount) || dayCount < 0) {
    throw new Error("dayCount must be a non-negative integer");
  }
  if (principalPaise === 0n || dayCount === 0) {
    return 0n;
  }
  const interest = paiseDecimal(principalPaise)
    .mul(parsePercent(annualRatePercent))
    .mul(dayCount)
    .div(100)
    .div(365);
  return halfUpPaise(interest);
}

export type EmiLine = {
  installmentNumber: number;
  openingPrincipalPaise: bigint;
  principalPaise: bigint;
  interestPaise: bigint;
  emiPaise: bigint;
  closingPrincipalPaise: bigint;
};

/**
 * Reducing-balance monthly EMI.
 * r = annualRatePercent / 100 / 12
 * EMI = P × r × (1+r)^n / ((1+r)^n − 1)
 * A zero rate uses EMI = round(P / n).
 * The last installment's principal is whatever is left, so the loan closes at zero.
 */
export function contractualEmiPaise(
  principalPaise: bigint,
  annualRatePercent: string,
  tenureMonths: number,
): bigint {
  if (principalPaise <= 0n) {
    throw new Error("principalPaise must be positive");
  }
  if (!Number.isInteger(tenureMonths) || tenureMonths <= 0) {
    throw new Error("tenureMonths must be a positive integer");
  }
  const annual = parsePercent(annualRatePercent);
  const principal = paiseDecimal(principalPaise);
  if (annual.isZero()) {
    return halfUpPaise(principal.div(tenureMonths));
  }
  const monthly = annual.div(100).div(12);
  const growth = monthly.plus(1).pow(tenureMonths);
  return halfUpPaise(
    principal.mul(monthly).mul(growth).div(growth.minus(1)),
  );
}

export function buildEmiSchedule(
  principalPaise: bigint,
  annualRatePercent: string,
  tenureMonths: number,
): { contractualEmiPaise: bigint; lines: EmiLine[] } {
  const emi = contractualEmiPaise(
    principalPaise,
    annualRatePercent,
    tenureMonths,
  );
  const monthly = parsePercent(annualRatePercent).div(100).div(12);
  let opening = principalPaise;
  const lines: EmiLine[] = [];

  for (let installmentNumber = 1; installmentNumber <= tenureMonths; installmentNumber += 1) {
    const interestPaise = halfUpPaise(paiseDecimal(opening).mul(monthly));
    const isLast = installmentNumber === tenureMonths;
    let principalPart: bigint;
    let lineEmi: bigint;
    if (isLast) {
      principalPart = opening;
      lineEmi = principalPart + interestPaise;
    } else {
      if (interestPaise >= emi) {
        throw new Error(
          "Monthly interest is not below the EMI. Check the rate and the tenure.",
        );
      }
      principalPart = emi - interestPaise;
      if (principalPart > opening) {
        principalPart = opening;
      }
      lineEmi = emi;
    }
    const closing = opening - principalPart;
    if (closing < 0n) {
      throw new Error("EMI schedule produced a negative principal");
    }
    lines.push({
      installmentNumber,
      openingPrincipalPaise: opening,
      principalPaise: principalPart,
      interestPaise,
      emiPaise: lineEmi,
      closingPrincipalPaise: closing,
    });
    opening = closing;
  }

  if (opening !== 0n) {
    throw new Error("EMI schedule did not clear the principal");
  }
  const principalSum = lines.reduce((sum, line) => sum + line.principalPaise, 0n);
  if (principalSum !== principalPaise) {
    throw new Error("EMI principal parts do not add up to the opening principal");
  }
  return { contractualEmiPaise: emi, lines };
}

export type GstPercents = {
  cgstPercent: string;
  sgstPercent: string;
  igstPercent: string;
  cessPercent: string;
};

export type GstSplit = {
  cgstPaise: bigint;
  sgstPaise: bigint;
  igstPaise: bigint;
  cessPaise: bigint;
  gstPaise: bigint;
};

/**
 * Intra-state uses CGST and SGST. Inter-state uses IGST.
 * Each component is rounded half-up to paise. If CGST + SGST differs from
 * the combined rate by one paise, the difference is added to SGST.
 */
export function splitGst(
  taxablePaise: bigint,
  rates: GstPercents,
  supply: "INTRA_STATE" | "INTER_STATE",
): GstSplit {
  if (taxablePaise < 0n) {
    throw new Error("taxablePaise cannot be negative");
  }
  const taxable = paiseDecimal(taxablePaise);
  const component = (percent: string) =>
    halfUpPaise(taxable.mul(parsePercent(percent)).div(100));

  let cgstPaise = 0n;
  let sgstPaise = 0n;
  let igstPaise = 0n;
  if (supply === "INTRA_STATE") {
    cgstPaise = component(rates.cgstPercent);
    sgstPaise = component(rates.sgstPercent);
    const combinedPercent = parsePercent(rates.cgstPercent).plus(
      parsePercent(rates.sgstPercent),
    );
    const combinedPaise = halfUpPaise(taxable.mul(combinedPercent).div(100));
    sgstPaise += combinedPaise - (cgstPaise + sgstPaise);
  } else if (supply === "INTER_STATE") {
    igstPaise = component(rates.igstPercent);
  } else {
    throw new Error("supply must be INTRA_STATE or INTER_STATE");
  }
  const cessPaise = component(rates.cessPercent);
  return {
    cgstPaise,
    sgstPaise,
    igstPaise,
    cessPaise,
    gstPaise: cgstPaise + sgstPaise + igstPaise + cessPaise,
  };
}

/**
 * Product rule for TDS, pending the firm's chartered accountant:
 * once year-to-date taxable for this vendor and section, including this bill,
 * is above the threshold, TDS is charged on the full taxable amount of this bill.
 * A null threshold means the section has no threshold.
 * A lower-deduction certificate is passed in as ratePercent by the caller.
 */
export function tdsPaise(input: {
  taxablePaise: bigint;
  ratePercent: string;
  thresholdPaise: bigint | null;
  ytdTaxableBeforePaise: bigint;
}): bigint {
  if (input.taxablePaise < 0n || input.ytdTaxableBeforePaise < 0n) {
    throw new Error("TDS amounts cannot be negative");
  }
  const ytdAfter = input.ytdTaxableBeforePaise + input.taxablePaise;
  if (input.thresholdPaise != null && ytdAfter <= input.thresholdPaise) {
    return 0n;
  }
  return halfUpPaise(
    paiseDecimal(input.taxablePaise).mul(parsePercent(input.ratePercent)).div(100),
  );
}

/**
 * Present = full daily wage. Half day = half, rounded half-up.
 * Absent = zero. Overtime is dailyWage × hours / 8, rounded half-up.
 * Overtime on an absent day is rejected so a bad mark is not silently paid.
 */
export function attendanceWagePaise(input: {
  dailyWagePaise: bigint;
  status: "PRESENT" | "ABSENT" | "HALF_DAY";
  overtimeHours: string;
}): bigint {
  if (input.dailyWagePaise < 0n) {
    throw new Error("dailyWagePaise cannot be negative");
  }
  const hours = new Decimal(input.overtimeHours);
  if (hours.isNeg()) {
    throw new Error("overtimeHours cannot be negative");
  }
  if (input.status === "ABSENT" && hours.gt(0)) {
    throw new Error("An absent day cannot also carry overtime");
  }
  const factor =
    input.status === "PRESENT" ? "1" : input.status === "HALF_DAY" ? "0.5" : "0";
  const base = halfUpPaise(paiseDecimal(input.dailyWagePaise).mul(factor));
  const overtime = halfUpPaise(
    hours.mul(paiseDecimal(input.dailyWagePaise)).div(8),
  );
  return base + overtime;
}

/** Weighted average after a receipt. Rates are rupees per unit. */
export function receiveStock(input: {
  oldQty: string;
  oldAverageRateRupees: string;
  inQty: string;
  inRateRupees: string;
}): { newQty: string; averageRateRupees: string; valuePaise: bigint } {
  const oldQty = new Decimal(input.oldQty);
  const inQty = new Decimal(input.inQty);
  if (oldQty.isNeg()) {
    throw new Error("oldQty cannot be negative");
  }
  if (inQty.lte(0)) {
    throw new Error("inQty must be positive");
  }
  const newQty = oldQty.plus(inQty);
  const average = oldQty
    .mul(input.oldAverageRateRupees)
    .plus(inQty.mul(input.inRateRupees))
    .div(newQty);
  return {
    newQty: newQty.toFixed(4),
    averageRateRupees: average.toFixed(6),
    valuePaise: halfUpPaise(inQty.mul(input.inRateRupees).mul(100)),
  };
}

/** Value of an issue at the current average, in paise. qty is a positive quantity. */
export function issueValuePaise(qty: string, averageRateRupees: string): bigint {
  const quantity = new Decimal(qty);
  if (quantity.lte(0)) {
    throw new Error("qty must be positive");
  }
  return halfUpPaise(quantity.mul(averageRateRupees).mul(100));
}

/**
 * Expected consumption = areaSqft × normQtyPerSqft × (1 + wastageAllowancePercent / 100).
 * The area must already be the project's cost-area basis (carpet, built-up, or super built-up).
 */
export function expectedMaterialQty(input: {
  areaSqft: string;
  normQtyPerSqft: string;
  wastageAllowancePercent: string;
}): string {
  const area = new Decimal(input.areaSqft);
  const norm = new Decimal(input.normQtyPerSqft);
  if (area.isNeg() || norm.isNeg()) {
    throw new Error("area and norm cannot be negative");
  }
  const allowance = parsePercent(input.wastageAllowancePercent);
  return area
    .mul(norm)
    .mul(new Decimal(1).plus(allowance.div(100)))
    .toFixed(4);
}

export function isExcessConsumption(actualQty: string, expectedQty: string): boolean {
  return new Decimal(actualQty).gt(expectedQty);
}
