import Decimal from "decimal.js";

import { halfUpPaise } from "./rounding";

const RUPEES = /^\d+(\.\d{1,2})?$/;

/** Turn a typed rupee amount into integer paise. ₹1.50 is 150. */
export function rupeesToPaise(input: string): bigint {
  const value = input.trim().replace(/,/g, "");
  if (!RUPEES.test(value)) {
    throw new Error("Enter rupees with at most two decimal places, such as 1000 or 1000.50.");
  }
  return halfUpPaise(new Decimal(value).times(100));
}

/** Show paise as rupees with lakh and crore grouping. */
export function formatInrFromPaise(paise: bigint): string {
  const negative = paise < 0n;
  const abs = negative ? -paise : paise;
  const fixed = new Decimal(abs.toString()).div(100).toFixed(2);
  const [whole, frac] = fixed.split(".");
  let grouped = whole ?? "0";
  if (grouped.length > 3) {
    const tail = grouped.slice(-3);
    const head = grouped.slice(0, -3).replace(/\B(?=(\d{2})+(?!\d))/g, ",");
    grouped = `${head},${tail}`;
  }
  return `${negative ? "−" : ""}₹${grouped}.${frac}`;
}
