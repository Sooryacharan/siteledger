import assert from "node:assert/strict";
import { describe, it } from "node:test";

import { bankFingerprint, invoiceFingerprint, normalizeIndianPhone, normalizeInvoiceNumber } from "./normalize";

describe("duplicate keys", () => {
  it("normalises Indian numbers to E.164", () => {
    assert.equal(normalizeIndianPhone("98765 43210"), "+919876543210");
    assert.equal(normalizeIndianPhone("09876543210"), "+919876543210");
    assert.equal(normalizeIndianPhone("+91-98765-43210"), "+919876543210");
    assert.equal(normalizeIndianPhone("12345"), null);
  });

  it("matches the same bank account however it was typed", () => {
    const first = bankFingerprint("hdfc0001234", "501 000 123456");
    const second = bankFingerprint("HDFC0001234", "501000123456");
    assert.equal(first, second);
    assert.equal(first.length, 64);
  });

  it("treats spaced invoice numbers as the same and hyphenated ones as different", () => {
    assert.equal(normalizeInvoiceNumber(" inv 12 "), "INV12");
    const spaced = invoiceFingerprint({
      vendorPartyId: "vendor",
      invoiceNumber: "INV 12",
      invoiceDate: "2026-04-02",
      totalPaise: 118000n,
    });
    const compact = invoiceFingerprint({
      vendorPartyId: "vendor",
      invoiceNumber: "inv12",
      invoiceDate: "2026-04-02",
      totalPaise: 118000n,
    });
    const hyphen = invoiceFingerprint({
      vendorPartyId: "vendor",
      invoiceNumber: "INV-12",
      invoiceDate: "2026-04-02",
      totalPaise: 118000n,
    });
    assert.equal(spaced, compact);
    assert.notEqual(spaced, hyphen);
  });
});
