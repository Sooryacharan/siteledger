const CHARSET = "0123456789ABCDEFGHIJKLMNOPQRSTUVWXYZ";
const PAN_SHAPE = /^[A-Z]{5}[0-9]{4}[A-Z]$/;

export type PanValidation =
  | { ok: true; pan: string }
  | { ok: false; reason: string };

export type GstinValidation =
  | { ok: true; gstin: string; stateCode: string; pan: string }
  | { ok: false; reason: string };

/** GSTIN check digit: Luhn mod 36, factor alternating 2, 1 from the right. */
export function gstinCheckDigit(first14: string): string {
  if (first14.length !== 14) {
    throw new Error("GSTIN check digit input must be 14 characters");
  }
  let factor = 2;
  let sum = 0;
  for (let index = first14.length - 1; index >= 0; index -= 1) {
    const code = CHARSET.indexOf(first14[index] ?? "");
    if (code < 0) {
      throw new Error("GSTIN contains a character outside 0-9 and A-Z");
    }
    let digit = factor * code;
    factor = factor === 2 ? 1 : 2;
    digit = Math.floor(digit / 36) + (digit % 36);
    sum += digit;
  }
  return CHARSET[(36 - (sum % 36)) % 36] ?? "";
}

export function validatePanShape(input: string): PanValidation {
  const pan = input.toUpperCase().replace(/\s+/g, "");
  if (!PAN_SHAPE.test(pan)) {
    return { ok: false, reason: "PAN must be 5 letters, 4 digits, and 1 letter" };
  }
  return { ok: true, pan };
}

/**
 * Structural GSTIN check plus the mod-36 check digit.
 * State codes 01–38 and 97 are accepted. The 14th character must be Z.
 * This does not ask the GST portal whether the taxpayer is active.
 */
export function validateGstin(input: string): GstinValidation {
  const gstin = input.toUpperCase().replace(/\s+/g, "");
  if (gstin.length !== 15) {
    return { ok: false, reason: "GSTIN must be 15 characters" };
  }
  if (!/^[0-9A-Z]+$/.test(gstin)) {
    return { ok: false, reason: "GSTIN has a character outside 0-9 and A-Z" };
  }
  const stateCode = gstin.slice(0, 2);
  const stateNumber = Number(stateCode);
  const stateOk = stateCode === "97" || (stateNumber >= 1 && stateNumber <= 38);
  if (!stateOk) {
    return { ok: false, reason: "GSTIN state code is not a recognised GST state" };
  }
  const pan = gstin.slice(2, 12);
  if (!PAN_SHAPE.test(pan)) {
    return { ok: false, reason: "GSTIN does not contain a PAN" };
  }
  const entity = gstin[12] ?? "";
  if (!/^[1-9A-Z]$/.test(entity)) {
    return { ok: false, reason: "GSTIN entity code is invalid" };
  }
  if (gstin[13] !== "Z") {
    return { ok: false, reason: "The 14th character of a GSTIN must be Z" };
  }
  const expected = gstinCheckDigit(gstin.slice(0, 14));
  if (gstin[14] !== expected) {
    return { ok: false, reason: "GSTIN check digit does not match" };
  }
  return { ok: true, gstin, stateCode, pan };
}
