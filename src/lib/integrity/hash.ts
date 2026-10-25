import { createHash } from "node:crypto";

export const GENESIS_HASH = "0".repeat(64);

export function sha256Hex(text: string): string {
  return createHash("sha256").update(text, "utf8").digest("hex");
}

export type JournalHashLine = {
  lineNumber: number;
  glAccountId: string;
  debitPaise: bigint;
  creditPaise: bigint;
  projectId?: string | null;
  costCentreId?: string | null;
  partyId?: string | null;
  unitId?: string | null;
};

function dash(value: string | null | undefined): string {
  return value == null || value === "" ? "-" : value;
}

function normalizeNarration(narration: string): string {
  return narration.normalize("NFC").replace(/\r?\n/g, " ").trim();
}

/**
 * Canonical journal payload, version journal.v1.
 * Lines are sorted by line number. Status is not included, so a later
 * POSTED → REVERSED flag does not rewrite the hash. The reversal is a new row.
 */
export function journalEntryHash(input: {
  prevHash: string;
  organizationId: string;
  entryId: string;
  entryDate: string;
  narration: string;
  source: string;
  sourceId?: string | null;
  lines: JournalHashLine[];
}): { body: string; hash: string } {
  const lines = [...input.lines].sort((a, b) => a.lineNumber - b.lineNumber);
  const body = [
    "journal.v1",
    input.organizationId,
    input.entryId,
    input.entryDate,
    normalizeNarration(input.narration),
    input.source,
    dash(input.sourceId),
    ...lines.map((line) =>
      [
        line.lineNumber,
        line.glAccountId,
        line.debitPaise.toString(),
        line.creditPaise.toString(),
        dash(line.projectId),
        dash(line.costCentreId),
        dash(line.partyId),
        dash(line.unitId),
      ].join("|"),
    ),
    input.prevHash,
  ].join("\n");
  return { body, hash: sha256Hex(body) };
}

export function stockEntryHash(input: {
  prevHash: string;
  organizationId: string;
  entryId: string;
  storeId: string;
  materialId: string;
  movement: string;
  quantity: string;
  valuePaise: bigint;
  occurredOn: string;
  sourceType: string;
  sourceId: string;
}): { body: string; hash: string } {
  const body = [
    "stock.v1",
    input.organizationId,
    input.entryId,
    input.storeId,
    input.materialId,
    input.movement,
    input.quantity,
    input.valuePaise.toString(),
    input.occurredOn,
    input.sourceType,
    input.sourceId,
    input.prevHash,
  ].join("\n");
  return { body, hash: sha256Hex(body) };
}

export function shareEntryHash(input: {
  prevHash: string;
  organizationId: string;
  entryId: string;
  projectId: string;
  partnerPartyId: string;
  entryType: string;
  entryDate: string;
  amountPaise: bigint;
  narration: string;
}): { body: string; hash: string } {
  const body = [
    "share.v1",
    input.organizationId,
    input.entryId,
    input.projectId,
    input.partnerPartyId,
    input.entryType,
    input.entryDate,
    input.amountPaise.toString(),
    normalizeNarration(input.narration),
    input.prevHash,
  ].join("\n");
  return { body, hash: sha256Hex(body) };
}

function sortJson(value: unknown): unknown {
  if (typeof value === "bigint") {
    throw new Error("Audit JSON cannot contain bigint. Store paise as strings.");
  }
  if (Array.isArray(value)) {
    return value.map(sortJson);
  }
  if (value && typeof value === "object") {
    const source = value as Record<string, unknown>;
    const sorted: Record<string, unknown> = {};
    for (const key of Object.keys(source).sort()) {
      sorted[key] = sortJson(source[key]);
    }
    return sorted;
  }
  return value;
}

export function stableJson(value: unknown): string {
  return JSON.stringify(sortJson(value ?? null));
}

export function auditEventHash(input: {
  prevHash: string;
  organizationId: string;
  eventId: string;
  actorId: string | null;
  action: string;
  entityType: string;
  entityId: string | null;
  occurredAt: string;
  before: unknown;
  after: unknown;
}): { body: string; hash: string } {
  const body = [
    "audit.v1",
    input.organizationId,
    input.eventId,
    dash(input.actorId),
    input.action,
    input.entityType,
    dash(input.entityId),
    input.occurredAt,
    stableJson(input.before),
    stableJson(input.after),
    input.prevHash,
  ].join("\n");
  return { body, hash: sha256Hex(body) };
}
