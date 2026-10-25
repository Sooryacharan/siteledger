import assert from "node:assert/strict";
import { describe, it } from "node:test";

import { validateGstin, validatePanShape } from "./gstin";

describe("GSTIN", () => {
  it("accepts a fictional Telangana GSTIN whose check digit was computed, not copied from a taxpayer", () => {
    const result = validateGstin("36aaaaa0000a1z3");
    assert.deepEqual(result, {
      ok: true,
      gstin: "36AAAAA0000A1Z3",
      stateCode: "36",
      pan: "AAAAA0000A",
    });
  });

  it("rejects a bad check digit, a bad state, and a PAN that is the wrong shape", () => {
    assert.equal(validateGstin("36AAAAA0000A1Z4").ok, false);
    assert.equal(validateGstin("99AAAAA0000A1Z5").ok, false);
    assert.equal(validatePanShape("AAAA0000A").ok, false);
    assert.deepEqual(validatePanShape("aaaaa0000a"), { ok: true, pan: "AAAAA0000A" });
  });
});
