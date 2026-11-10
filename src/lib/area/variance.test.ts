import assert from "node:assert/strict";
import { describe, it } from "node:test";

import { builtVersusApproved, parseSqft } from "./variance";

describe("built versus approved area", () => {
  it("warns when the built area is more than the project percent above the approved area", () => {
    const result = builtVersusApproved({
      approvedSqft: "1680",
      builtSqft: "1740",
      alertPercent: "2",
    });
    assert.equal(result.differenceSqft, "60.000");
    assert.equal(result.percent, "3.57");
    assert.equal(result.exceeds, true);
  });

  it("does not warn when the difference is exactly the allowance", () => {
    const result = builtVersusApproved({
      approvedSqft: "1000",
      builtSqft: "1020",
      alertPercent: "2",
    });
    assert.equal(result.percent, "2.00");
    assert.equal(result.exceeds, false);
  });

  it("warns when something was built and nothing was approved", () => {
    const result = builtVersusApproved({
      approvedSqft: "0",
      builtSqft: "10",
      alertPercent: "2",
    });
    assert.equal(result.percent, null);
    assert.equal(result.exceeds, true);
  });

  it("stays quiet when both figures are zero", () => {
    const result = builtVersusApproved({
      approvedSqft: "0",
      builtSqft: "0",
      alertPercent: "2",
    });
    assert.equal(result.exceeds, false);
  });

  it("rejects a negative area and a fourth decimal place", () => {
    assert.throws(() => parseSqft("-1"));
    assert.throws(() => parseSqft("1.2345"));
    assert.equal(parseSqft("980.5").toFixed(3), "980.500");
  });
});
