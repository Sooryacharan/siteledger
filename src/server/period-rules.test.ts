import assert from "node:assert/strict";
import { describe, it } from "node:test";

import { AccessError } from "./errors";
import { nextPeriodStatus } from "./period-rules";

describe("period moves", () => {
  it("walks open, then soft-closed, then locked", () => {
    assert.equal(nextPeriodStatus("OPEN", "SOFT_CLOSE", "FINANCE"), "SOFT_CLOSED");
    assert.equal(nextPeriodStatus("SOFT_CLOSED", "LOCK", "FINANCE"), "LOCKED");
    assert.throws(
      () => nextPeriodStatus("OPEN", "LOCK", "OWNER"),
      (error: unknown) => error instanceof AccessError,
    );
  });

  it("lets only an owner reopen a locked period", () => {
    assert.equal(nextPeriodStatus("LOCKED", "REOPEN", "OWNER"), "OPEN");
    assert.throws(
      () => nextPeriodStatus("LOCKED", "REOPEN", "FINANCE"),
      (error: unknown) => error instanceof AccessError && error.code === "PERIOD",
    );
    assert.throws(
      () => nextPeriodStatus("LOCKED", "REOPEN", "AUDITOR"),
      (error: unknown) => error instanceof AccessError,
    );
  });
});
