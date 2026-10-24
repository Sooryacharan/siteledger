import Decimal from "decimal.js";

Decimal.set({ precision: 40, rounding: Decimal.ROUND_HALF_UP });

const RATE_PATTERN = /^\d+(\.\d{1,4})?$/;

/** A percent such as "18" or "18.5". At most four decimal places. 18 means 18%. */
export function parsePercent(percent: string): Decimal {
  if (!RATE_PATTERN.test(percent)) {
    throw new Error(
      `Percent must be a non-negative decimal with at most 4 places, received "${percent}"`,
    );
  }
  return new Decimal(percent);
}

/** Half away from zero, to an integer number of paise. */
export function halfUpPaise(value: Decimal): bigint {
  return BigInt(value.toDecimalPlaces(0, Decimal.ROUND_HALF_UP).toFixed(0));
}

export function paiseDecimal(paise: bigint): Decimal {
  return new Decimal(paise.toString());
}
