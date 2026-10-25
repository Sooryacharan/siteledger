import type { Prisma, RecordRef } from "@prisma/client";

import { GENESIS_HASH, auditEventHash } from "@/lib/integrity/hash";

import { findChainBreak, type ChainReport } from "./chain";
import { appendAudit, withTenant } from "./db";
import { assertCan } from "./permissions";
import type { TenantContext } from "./tenant";

export async function recordExport(
  ctx: TenantContext,
  input: { entityType: RecordRef; entityId: string },
): Promise<void> {
  assertCan(ctx.role, "export");
  await withTenant(ctx, async (tx) => {
    await appendAudit(tx, ctx, {
      action: "EXPORT",
      entityType: input.entityType,
      entityId: input.entityId,
      before: null,
      after: { kind: "export" },
    });
  });
}

export async function verifyAuditChain(
  tx: Prisma.TransactionClient,
  organizationId: string,
): Promise<ChainReport> {
  const [events, head] = await Promise.all([
    tx.auditEvent.findMany({
      where: { organizationId },
      orderBy: { sequence: "asc" },
    }),
    tx.chainHead.findUnique({
      where: { organizationId_chain: { organizationId, chain: "AUDIT" } },
    }),
  ]);
  if (!head) {
    return { ok: false, sequence: null, reason: "audit chain head is missing" };
  }
  return findChainBreak({
    headHash: head.lastHash,
    headSequence: head.lastSequence,
    rows: events.map((event) => ({
      sequence: event.sequence,
      prevHash: event.prevHash,
      entryHash: event.eventHash,
      expectedHash: auditEventHash({
        prevHash: event.prevHash,
        organizationId,
        eventId: event.id,
        actorId: event.actorId,
        action: event.action,
        entityType: event.entityType,
        entityId: event.entityId,
        occurredAt: event.occurredAt.toISOString(),
        before: event.before,
        after: event.after,
      }).hash,
    })),
  });
}

export { GENESIS_HASH };
