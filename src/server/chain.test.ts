import assert from "node:assert/strict";
import { describe, it } from "node:test";

import { GENESIS_HASH } from "@/lib/integrity/hash";

import { findChainBreak } from "./chain";

describe("chain walk", () => {
  it("accepts a single row that starts at the genesis hash", () => {
    const report = findChainBreak({
      rows: [
        {
          sequence: 1,
          prevHash: GENESIS_HASH,
          entryHash: "abc",
          expectedHash: "abc",
        },
      ],
      headHash: "abc",
      headSequence: 1,
    });
    assert.deepEqual(report, { ok: true });
  });

  it("reports a payload that was changed after the hash was written", () => {
    const report = findChainBreak({
      rows: [
        {
          sequence: 1,
          prevHash: GENESIS_HASH,
          entryHash: "stored",
          expectedHash: "recomputed",
        },
      ],
      headHash: "stored",
      headSequence: 1,
    });
    assert.equal(report.ok, false);
    if (!report.ok) {
      assert.equal(report.sequence, 1);
      assert.match(report.reason, /payload/);
    }
  });
});
