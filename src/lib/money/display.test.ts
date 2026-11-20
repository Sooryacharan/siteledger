import assert from "node:assert/strict";
import { describe, it } from "node:test";

import { formatInrFromPaise, rupeesToPaise } from "./display";

describe("rupee display", () => {
  it("turns ₹1,000.50 into 100050 paise and back", () => {
    assert.equal(rupeesToPaise("1000.50"), 100050n);
    assert.equal(formatInrFromPaise(100050n), "₹1,000.50");
  });

  it("groups a lakh", () => {
    assert.equal(formatInrFromPaise(10000000n), "₹1,00,000.00");
  });

  it("rejects a third decimal place", () => {
    assert.throws(() => rupeesToPaise("1.005"));
  });
});
