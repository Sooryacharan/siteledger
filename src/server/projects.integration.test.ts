import assert from "node:assert/strict";
import { randomUUID } from "node:crypto";
import { after, describe, it } from "node:test";

import type { MembershipRole } from "@prisma/client";

import { GENESIS_HASH } from "@/lib/integrity/hash";

import { disconnectDatabases, ownerDb, withTenant } from "./db";
import { addTower, addUnit, createProject, getProject, listProjects, recordAreas } from "./projects";
import type { TenantContext } from "./tenant";

const CHAINS = ["JOURNAL", "STOCK", "SHARE", "AUDIT"] as const;

function context(input: {
  organizationId: string;
  userId: string;
  role: MembershipRole;
}): TenantContext {
  return {
    organizationId: input.organizationId,
    userId: input.userId,
    role: input.role,
    partyId: null,
    ipAddress: "203.0.113.20",
    userAgent: "SiteLedgerTest/1",
    deviceId: null,
    requestId: "req-projects",
  };
}

async function makeFirm(prefix: string) {
  const slug = `${prefix}-${randomUUID().slice(0, 8)}`;
  const org = await ownerDb.organization.create({
    data: { slug, legalName: `${prefix} Developers`, displayName: prefix, stateCode: "36" },
  });
  await ownerDb.chainHead.createMany({
    data: CHAINS.map((chain) => ({
      organizationId: org.id,
      chain,
      lastHash: GENESIS_HASH,
      lastSequence: 0,
    })),
  });
  async function member(role: MembershipRole) {
    const user = await ownerDb.user.create({
      data: { email: `${role.toLowerCase()}.${randomUUID().slice(0, 8)}@${slug}.example`, name: `${prefix} ${role}` },
    });
    await ownerDb.membership.create({
      data: { organizationId: org.id, userId: user.id, role },
    });
    return { user, ctx: context({ organizationId: org.id, userId: user.id, role }) };
  }
  return { org, member };
}

async function messageOf(fn: () => Promise<unknown>): Promise<string> {
  try {
    await fn();
  } catch (error) {
    return error instanceof Error ? error.message : String(error);
  }
  throw new Error("expected the call to fail");
}

describe("projects and units", () => {
  after(async () => {
    await disconnectDatabases();
  });

  it("builds a project, flags a built area over the allowance, and writes an audit row", async () => {
    const firm = await makeFirm("Cedar");
    const owner = await firm.member("OWNER");
    const site = await firm.member("SITE_ENGINEER");
    const sales = await firm.member("SALES");
    const auditor = await firm.member("AUDITOR");
    const other = await makeFirm("Teak");
    const otherOwner = await other.member("OWNER");

    const project = await createProject(owner.ctx, {
      code: "CEDAR",
      name: "Cedar Court",
      city: "Hyderabad",
      stateCode: "36",
    });
    const phase = await ownerDb.projectPhase.create({
      data: { organizationId: firm.org.id, projectId: project.id, name: "Phase 1", sortOrder: 1 },
    });
    await addTower(owner.ctx, project.id, "Tower A", phase.id);
    const tower = await ownerDb.tower.findFirstOrThrow({ where: { projectId: project.id, name: "Tower A" } });
    const floor = await ownerDb.floor.create({
      data: {
        organizationId: firm.org.id,
        projectId: project.id,
        towerId: tower.id,
        levelNumber: 1,
        label: "First floor",
      },
    });
    const unit = await addUnit(owner.ctx, {
      projectId: project.id,
      floorId: floor.id,
      flatNumber: "A-101",
      facing: "NORTH",
      areas: {
        superBuiltUpPlannedSqft: "1680",
        superBuiltUpApprovedSqft: "1680",
        superBuiltUpBuiltSqft: "1680",
      },
    });
    await ownerDb.projectAssignment.create({
      data: { organizationId: firm.org.id, projectId: project.id, userId: site.user.id, createdById: owner.user.id },
    });
    await recordAreas(site.ctx, {
      unitId: unit.id,
      reason: "Site tape showed an extra 60 sqft",
      areas: { superBuiltUpBuiltSqft: "1740" },
    });

    const detail = await getProject(owner.ctx, project.id);
    assert.equal(detail.alerts.length, 1);
    assert.match(detail.alerts[0]?.sentence ?? "", /A-101/);
    assert.match(detail.alerts[0]?.sentence ?? "", /3\.57%/);

    const hidden = await listProjects(sales.ctx);
    assert.equal(hidden.length, 0);
    await ownerDb.projectAssignment.create({
      data: { organizationId: firm.org.id, projectId: project.id, userId: sales.user.id, createdById: owner.user.id },
    });
    const visible = await listProjects(sales.ctx);
    assert.deepEqual(visible.map((row) => row.name), ["Cedar Court"]);
    const salesWrite = await messageOf(() => addTower(sales.ctx, project.id, "Tower B", phase.id));
    assert.match(salesWrite, /cannot change the building/);

    const auditorWrite = await messageOf(() =>
      recordAreas(auditor.ctx, {
        unitId: unit.id,
        reason: "An auditor must not change this",
        areas: { superBuiltUpBuiltSqft: "1000" },
      }),
    );
    assert.match(auditorWrite, /cannot record what was built|AUDITOR cannot write/);

    const foreign = await messageOf(() => getProject(otherOwner.ctx, project.id));
    assert.match(foreign, /not in this firm|not assigned/);

    const revision = await ownerDb.unitAreaRevision.findFirstOrThrow({
      where: { unitId: unit.id, field: "SUPER_BUILT_UP_BUILT", newSqft: "1740.000" },
    });
    const tamper = await messageOf(() =>
      ownerDb.unitAreaRevision.update({ where: { id: revision.id }, data: { reason: "rewritten" } }),
    );
    assert.match(tamper, /append-only/);

    const audit = await withTenant(owner.ctx, (tx) =>
      tx.auditEvent.findFirst({
        where: { entityId: unit.id, action: "UPDATE" },
        orderBy: { sequence: "desc" },
      }),
    );
    assert.equal(audit?.actorId, site.user.id);
    assert.equal(audit?.ipAddress, "203.0.113.20");
    const beforeSqft = String((audit?.before as { superBuiltUpBuiltSqft?: string } | null)?.superBuiltUpBuiltSqft ?? "");
    const afterSqft = String((audit?.after as { superBuiltUpBuiltSqft?: string } | null)?.superBuiltUpBuiltSqft ?? "");
    assert.match(beforeSqft, /^1680(\.0+)?$/);
    assert.match(afterSqft, /^1740(\.0+)?$/);
  });
});
