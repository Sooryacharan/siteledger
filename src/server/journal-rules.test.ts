import assert from "node:assert/strict";
import { describe, it } from "node:test";

import { AccessError } from "./errors";
import { assertJournalLines } from "./journal";

describe("journal balance", () => {
  it("accepts two lines that meet in the middle", () => {
    assert.doesNotThrow(() =>
      assertJournalLines([
        { glAccountId: "cash", debitPaise: 150n, creditPaise: 0n },
        { glAccountId: "capital", debitPaise: 0n, creditPaise: 150n },
      ]),
    );
  });

  it("rejects a journal that does not balance", () => {
    assert.throws(
      () =>
        assertJournalLines([
          { glAccountId: "cash", debitPaise: 150n, creditPaise: 0n },
          { glAccountId: "capital", debitPaise: 0n, creditPaise: 100n },
        ]),
      (error: unknown) => error instanceof AccessError && /do not balance/.test(error.message),
    );
  });

  it("rejects a line that is both money in and money out", () => {
    assert.throws(
      () =>
        assertJournalLines([
          { glAccountId: "cash", debitPaise: 10n, creditPaise: 10n },
          { glAccountId: "capital", debitPaise: 0n, creditPaise: 10n },
        ]),
      (error: unknown) => error instanceof AccessError,
    );
  });
});
