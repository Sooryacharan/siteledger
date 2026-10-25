import { Prisma, PrismaClient, type AuditAction, type RecordRef } from "@prisma/client";

import { auditEventHash } from "@/lib/integrity/hash";

import { AccessError } from "./errors";
import { can } from "./permissions";
import { applySession, tenantStore, type TenantContext } from "./tenant";

const WRITE_OPERATIONS = new Set([
  "create",
  "update",
  "upsert",
  "delete",
  "createMany",
  "createManyAndReturn",
  "updateMany",
  "updateManyAndReturn",
  "deleteMany",
]);

const BULK_OPERATIONS = new Set([
  "createMany",
  "createManyAndReturn",
  "updateMany",
  "updateManyAndReturn",
  "deleteMany",
]);

/** Models the audit log is allowed to name. Chain heads move only through app.advance_chain_head. */
const ENTITY_TYPE: Record<string, RecordRef> = {
  Organization: "ORGANIZATION",
  User: "USER",
  Membership: "MEMBERSHIP",
  ProjectAssignment: "PROJECT_ASSIGNMENT",
  Device: "DEVICE",
  ApprovalPolicy: "APPROVAL_POLICY",
  ApprovalRequest: "APPROVAL_REQUEST",
  ApprovalAction: "APPROVAL_ACTION",
  FiscalYear: "FISCAL_YEAR",
  AccountingPeriod: "ACCOUNTING_PERIOD",
  PeriodLockEvent: "PERIOD_LOCK_EVENT",
  Party: "PARTY",
  Project: "PROJECT",
  Lead: "LEAD",
  GlAccount: "GL_ACCOUNT",
  JournalEntry: "JOURNAL_ENTRY",
  JournalLine: "JOURNAL_LINE",
};

function delegateKey(model: string): string {
  return model.charAt(0).toLowerCase() + model.slice(1);
}

function snapshot(row: unknown): Record<string, unknown> | null {
  if (!row || typeof row !== "object") return null;
  const out: Record<string, unknown> = {};
  for (const [key, value] of Object.entries(row)) {
    if (value === undefined) continue;
    if (typeof value === "bigint") {
      out[key] = value.toString();
      continue;
    }
    if (value instanceof Date) {
      out[key] = value.toISOString();
      continue;
    }
    if (typeof value === "object" && value !== null) {
      if (typeof (value as { toFixed?: unknown }).toFixed === "function") {
        out[key] = (value as { toString(): string }).toString();
        continue;
      }
      continue;
    }
    out[key] = value;
  }
  return out;
}

type LockRow = { last_hash: string; last_sequence: number };

export async function appendAudit(
  tx: Prisma.TransactionClient,
  ctx: TenantContext,
  input: {
    action: AuditAction;
    entityType: RecordRef;
    entityId: string | null;
    before: Record<string, unknown> | null;
    after: Record<string, unknown> | null;
  },
): Promise<void> {
  if (ctx.role === "AUDITOR" && input.action !== "EXPORT" && input.action !== "LOGIN") {
    throw new AccessError("an auditor cannot write", "FORBIDDEN");
  }

  const store = tenantStore.getStore();
  const previous = store?.inAudit ?? false;
  if (store) store.inAudit = true;
  try {
    const locked = await tx.$queryRaw<LockRow[]>`
      SELECT last_hash, last_sequence
      FROM app.lock_chain_head(${ctx.organizationId}::uuid, ${"AUDIT"})
    `;
    const head = locked[0];
    if (!head) {
      throw new AccessError("this firm has no audit chain head", "CHAIN");
    }
    const sequence = Number(head.last_sequence) + 1;
    const eventId = crypto.randomUUID();
    const occurredAt = new Date();
    const { hash } = auditEventHash({
      prevHash: head.last_hash,
      organizationId: ctx.organizationId,
      eventId,
      actorId: ctx.userId,
      action: input.action,
      entityType: input.entityType,
      entityId: input.entityId,
      occurredAt: occurredAt.toISOString(),
      before: input.before,
      after: input.after,
    });
    await tx.auditEvent.create({
      data: {
        id: eventId,
        organizationId: ctx.organizationId,
        actorId: ctx.userId,
        action: input.action,
        entityType: input.entityType,
        entityId: input.entityId,
        occurredAt,
        before: input.before === null ? undefined : (input.before as Prisma.InputJsonValue),
        after: input.after === null ? undefined : (input.after as Prisma.InputJsonValue),
        requestId: ctx.requestId,
        ipAddress: ctx.ipAddress,
        userAgent: ctx.userAgent,
        deviceId: ctx.deviceId,
        sequence,
        prevHash: head.last_hash,
        eventHash: hash,
      },
    });
    await tx.$executeRaw`
      SELECT app.advance_chain_head(
        ${ctx.organizationId}::uuid,
        ${"AUDIT"},
        ${hash},
        ${sequence}::integer
      )
    `;
  } finally {
    if (store) store.inAudit = previous;
  }
}

function extend(base: PrismaClient) {
  return base.$extends({
    query: {
      $allModels: {
        async $allOperations({ model, operation, args, query }) {
          const store = tenantStore.getStore();
          if (!WRITE_OPERATIONS.has(operation)) {
            if (!store) {
              throw new AccessError("a tenant session is required before reading", "TENANT");
            }
            return query(args);
          }
          if (!store) {
            throw new AccessError("a tenant session is required before writing", "TENANT");
          }
          if (operation === "delete" || operation === "deleteMany") {
            throw new AccessError(
              `${model} cannot be deleted. Correct it with a reversal or a soft delete.`,
              "DELETE",
            );
          }
          if (BULK_OPERATIONS.has(operation)) {
            throw new AccessError(
              "write one row at a time so the audit log can store the old and new values",
              "AUDIT",
            );
          }
          if (store.inAudit || model === "AuditEvent") {
            if (model === "AuditEvent" && !store.inAudit) {
              throw new AccessError("audit rows are written by the audit log", "AUDIT");
            }
            return query(args);
          }
          if (model === "ChainHead") {
            throw new AccessError("chain heads move only through the hash helper", "CHAIN");
          }
          const entityType = ENTITY_TYPE[model];
          if (!entityType) {
            throw new AccessError(`${model} is not on the audit map`, "AUDIT");
          }
          if (!can(store.ctx.role, "write")) {
            throw new AccessError(`${store.ctx.role} cannot write`, "FORBIDDEN");
          }

          const whereId = (args as { where?: { id?: string } }).where?.id;
          let before: Record<string, unknown> | null = null;
          if (operation === "update" || operation === "upsert") {
            if (!whereId) {
              throw new AccessError("an audited update needs the row id", "AUDIT");
            }
            const existing = await (
              store.tx as unknown as Record<
                string,
                { findUnique(input: { where: { id: string } }): Promise<unknown> }
              >
            )[delegateKey(model)].findUnique({ where: { id: whereId } });
            before = snapshot(existing);
          }

          const result = await query(args);
          const after = snapshot(result);
          let action: AuditAction = store.actionOverride ?? "UPDATE";
          if (!store.actionOverride) {
            const removed = before?.deletedAt == null && after?.deletedAt != null;
            if (removed) action = "SOFT_DELETE";
            else if (operation === "create" || before == null) action = "CREATE";
          }
          const entityId =
            (after?.id as string | undefined) ??
            whereId ??
            null;
          await appendAudit(store.tx, store.ctx, {
            action,
            entityType,
            entityId,
            before,
            after,
          });
          return result;
        },
      },
    },
  });
}

function databaseUrl(name: "DATABASE_URL" | "APP_DATABASE_URL"): string {
  const value = process.env[name];
  if (!value) {
    throw new Error(`${name} is not set. Copy .env.example to .env.`);
  }
  return value;
}

/** Migration owner. Bypasses row-level security. Used for sign-in, seed, and tamper checks. */
export const ownerDb = new PrismaClient({
  datasources: { db: { url: databaseUrl("DATABASE_URL") } },
});

const appBase = new PrismaClient({
  datasources: { db: { url: databaseUrl("APP_DATABASE_URL") } },
});

/** Application connection. Every read and write runs inside withTenant. */
export const appDb = extend(appBase);

export type AppTx = Parameters<Parameters<typeof appDb.$transaction>[0]>[0];

export async function withTenant<T>(
  ctx: TenantContext,
  fn: (tx: AppTx) => Promise<T>,
): Promise<T> {
  const bound = await bindMembership(ctx);
  return appDb.$transaction(async (tx) => {
    const store = {
      ctx: bound,
      tx: tx as unknown as Prisma.TransactionClient,
      inAudit: false,
      actionOverride: null as import("@prisma/client").AuditAction | null,
    };
    // Await inside the store. A bare Prisma promise is only started once
    // $transaction awaits it, which would be outside the store.
    return tenantStore.run(store, async () => {
      await applySession(tx, bound);
      return fn(tx);
    });
  });
}

async function bindMembership(ctx: TenantContext): Promise<TenantContext> {
  const membership = await ownerDb.membership.findFirst({
    where: {
      userId: ctx.userId,
      organizationId: ctx.organizationId,
      role: ctx.role,
      isActive: true,
      deletedAt: null,
      user: { deletedAt: null },
      organization: { deletedAt: null },
    },
  });
  if (!membership) {
    throw new AccessError("no active membership for this firm and role", "TENANT");
  }
  return {
    ...ctx,
    partyId: membership.partyId,
  };
}

export async function disconnectDatabases(): Promise<void> {
  await Promise.all([ownerDb.$disconnect(), appBase.$disconnect()]);
}
