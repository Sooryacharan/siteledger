import { GENESIS_HASH } from "@/lib/integrity/hash";

export type ChainRow = {
  sequence: number;
  prevHash: string;
  entryHash: string;
  expectedHash: string;
};

export type ChainReport =
  | { ok: true }
  | { ok: false; sequence: number | null; reason: string };

/** Walk a chain in sequence order and report the first row that does not match. */
export function findChainBreak(input: {
  rows: ChainRow[];
  headHash: string;
  headSequence: number;
}): ChainReport {
  let previous = GENESIS_HASH;
  for (const row of input.rows) {
    if (row.prevHash !== previous) {
      return {
        ok: false,
        sequence: row.sequence,
        reason: "previous hash does not match the prior row",
      };
    }
    if (row.entryHash !== row.expectedHash) {
      return {
        ok: false,
        sequence: row.sequence,
        reason: "row hash does not match its payload",
      };
    }
    previous = row.entryHash;
  }
  if (input.headSequence !== input.rows.length || input.headHash !== previous) {
    return {
      ok: false,
      sequence: null,
      reason: "chain head does not match the last row",
    };
  }
  return { ok: true };
}
