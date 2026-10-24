import assert from "node:assert/strict";
import { describe, it } from "node:test";

import { GENESIS_HASH, journalEntryHash, sha256Hex, stableJson } from "./hash";

describe("journal hash", () => {
  const lines = [
    {
      lineNumber: 2,
      glAccountId: "credit",
      debitPaise: 0n,
      creditPaise: 100n,
      partyId: "vendor",
    },
    {
      lineNumber: 1,
      glAccountId: "debit",
      debitPaise: 100n,
      creditPaise: 0n,
    },
  ];

  it("builds one canonical body and ignores the order the lines were passed in", () => {
    const first = journalEntryHash({
      prevHash: GENESIS_HASH,
      organizationId: "org",
      entryId: "entry",
      entryDate: "2026-04-01",
      narration: "Cement\npurchase",
      source: "VENDOR_INVOICE",
      sourceId: "inv",
      lines,
    });
    const reversed = journalEntryHash({
      prevHash: GENESIS_HASH,
      organizationId: "org",
      entryId: "entry",
      entryDate: "2026-04-01",
      narration: "Cement purchase",
      source: "VENDOR_INVOICE",
      sourceId: "inv",
      lines: [...lines].reverse(),
    });
    const body = [
      "journal.v1",
      "org",
      "entry",
      "2026-04-01",
      "Cement purchase",
      "VENDOR_INVOICE",
      "inv",
      "1|debit|100|0|-|-|-|-",
      "2|credit|0|100|-|-|vendor|-",
      GENESIS_HASH,
    ].join("\n");
    assert.equal(first.body, body);
    assert.equal(reversed.hash, first.hash);
    assert.equal(first.hash, sha256Hex(body));
    assert.match(first.hash, /^[0-9a-f]{64}$/);
  });

  it("changes when a paise amount changes", () => {
    const original = journalEntryHash({
      prevHash: GENESIS_HASH,
      organizationId: "org",
      entryId: "entry",
      entryDate: "2026-04-01",
      narration: "Cement purchase",
      source: "VENDOR_INVOICE",
      sourceId: "inv",
      lines,
    });
    const edited = journalEntryHash({
      prevHash: GENESIS_HASH,
      organizationId: "org",
      entryId: "entry",
      entryDate: "2026-04-01",
      narration: "Cement purchase",
      source: "VENDOR_INVOICE",
      sourceId: "inv",
      lines: lines.map((line) =>
        line.lineNumber === 1 ? { ...line, debitPaise: 101n } : line,
      ),
    });
    assert.notEqual(original.hash, edited.hash);
  });
});

describe("audit json", () => {
  it("sorts keys and rejects bigint", () => {
    assert.equal(stableJson({ b: 1, a: { d: 2, c: 3 } }), '{"a":{"c":3,"d":2},"b":1}');
    assert.throws(() => stableJson({ paise: 10n }));
  });
});
