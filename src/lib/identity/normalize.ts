import { sha256Hex } from "../integrity/hash";

/** Indian phone to E.164. Returns null when the number is not 10 digits after a 0 or 91 prefix. */
export function normalizeIndianPhone(input: string): string | null {
  const digits = input.trim().replace(/\D/g, "");
  let national = "";
  if (digits.length === 10) {
    national = digits;
  } else if (digits.length === 11 && digits.startsWith("0")) {
    national = digits.slice(1);
  } else if (digits.length === 12 && digits.startsWith("91")) {
    national = digits.slice(2);
  } else {
    return null;
  }
  return `+91${national}`;
}

const IFSC_SHAPE = /^[A-Z]{4}0[A-Z0-9]{6}$/;

/** sha256 of uppercase IFSC, a pipe, and the digits of the account number. */
export function bankFingerprint(ifsc: string, accountNumber: string): string {
  const normalizedIfsc = ifsc.toUpperCase().replace(/\s+/g, "");
  if (!IFSC_SHAPE.test(normalizedIfsc)) {
    throw new Error("IFSC is not 4 letters, a 0, and 6 letters or digits");
  }
  const digits = accountNumber.replace(/\D/g, "");
  if (digits.length < 6 || digits.length > 18) {
    throw new Error("Account number should be 6 to 18 digits");
  }
  return sha256Hex(`${normalizedIfsc}|${digits}`);
}

/** Uppercase, with every space removed. Hyphens stay, so INV-12 and INV12 do not match. */
export function normalizeInvoiceNumber(value: string): string {
  return value.trim().toUpperCase().replace(/\s+/g, "");
}

export function invoiceFingerprint(input: {
  vendorPartyId: string;
  invoiceNumber: string;
  invoiceDate: string;
  totalPaise: bigint;
}): string {
  if (!/^\d{4}-\d{2}-\d{2}$/.test(input.invoiceDate)) {
    throw new Error("invoiceDate must be YYYY-MM-DD");
  }
  const invoiceNumber = normalizeInvoiceNumber(input.invoiceNumber);
  if (!invoiceNumber) {
    throw new Error("Invoice number is empty");
  }
  return sha256Hex(
    `${input.vendorPartyId}|${invoiceNumber}|${input.invoiceDate}|${input.totalPaise.toString()}`,
  );
}
