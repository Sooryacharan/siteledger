import type {
  CostAreaBasis,
  MembershipRole,
  Prisma,
  UnitFacing,
  UnitStatus,
} from "@prisma/client";

import {
  AREA_FIELDS,
  basisLabel,
  builtVersusApproved,
  formatSqft,
  parseSqft,
} from "@/lib/area/variance";

import { withTenant, type AppTx } from "./db";
import { AccessError } from "./errors";
import { seesWholeFirm } from "./permissions";
import type { TenantContext } from "./tenant";

const STRUCTURE = new Set<MembershipRole>(["OWNER", "FINANCE", "PROJECT_MANAGER"]);
const SITE = new Set<MembershipRole>(["OWNER", "FINANCE", "PROJECT_MANAGER", "SITE_ENGINEER"]);

export function canChangeStructure(role: MembershipRole): boolean {
  return STRUCTURE.has(role);
}

export function canChangeBuiltArea(role: MembershipRole): boolean {
  return SITE.has(role);
}

function assertStructure(role: MembershipRole): void {
  if (!canChangeStructure(role)) {
    throw new AccessError(`${role} cannot change the building`, "FORBIDDEN");
  }
}

function assertBuilt(role: MembershipRole): void {
  if (!canChangeBuiltArea(role)) {
    throw new AccessError(`${role} cannot record what was built`, "FORBIDDEN");
  }
}

async function visibleProjectIds(tx: AppTx, ctx: TenantContext): Promise<string[] | null> {
  if (seesWholeFirm(ctx.role)) return null;
  const rows = await tx.projectAssignment.findMany({
    where: { userId: ctx.userId, deletedAt: null },
    select: { projectId: true },
  });
  return rows.map((row) => row.projectId);
}

async function assertCanSeeProject(tx: AppTx, ctx: TenantContext, projectId: string): Promise<void> {
  const allowed = await visibleProjectIds(tx, ctx);
  if (allowed && !allowed.includes(projectId)) {
    throw new AccessError("that project is not assigned to you", "FORBIDDEN");
  }
}

const projectInclude = {
  phases: { where: { deletedAt: null }, orderBy: { sortOrder: "asc" as const } },
  towers: {
    where: { deletedAt: null },
    orderBy: { name: "asc" as const },
    include: {
      floors: {
        where: { deletedAt: null },
        orderBy: { levelNumber: "asc" as const },
        include: {
          units: { where: { deletedAt: null }, orderBy: { flatNumber: "asc" as const } },
        },
      },
    },
  },
  units: { where: { deletedAt: null }, orderBy: { flatNumber: "asc" as const } },
} satisfies Prisma.ProjectInclude;

type ProjectRow = Prisma.ProjectGetPayload<{ include: typeof projectInclude }>;

export type UnitView = {
  id: string;
  flatNumber: string;
  facing: UnitFacing | null;
  status: UnitStatus;
  floorId: string | null;
  areas: Record<(typeof AREA_FIELDS)[number]["key"], string>;
  removed: boolean;
};

export type AreaAlert = {
  unitId: string;
  flatNumber: string;
  sentence: string;
};

export type ProjectDetail = {
  id: string;
  code: string;
  name: string;
  city: string | null;
  status: string;
  costAreaBasis: CostAreaBasis;
  basisName: string;
  alertPercent: string;
  nextStep: string;
  phases: Array<{ id: string; name: string }>;
  towers: Array<{
    id: string;
    name: string;
    floors: Array<{ id: string; label: string; levelNumber: number; units: UnitView[] }>;
  }>;
  alerts: AreaAlert[];
};

function unitView(unit: ProjectRow["units"][number], removed = false): UnitView {
  const areas = {} as UnitView["areas"];
  for (const field of AREA_FIELDS) {
    areas[field.key] = formatSqft(unit[field.key].toString());
  }
  return {
    id: unit.id,
    flatNumber: unit.flatNumber,
    facing: unit.facing,
    status: unit.status,
    floorId: unit.floorId,
    areas,
    removed,
  };
}

function alertsFor(project: { costAreaBasis: CostAreaBasis; areaVarianceAlertPercent: { toString(): string } }, units: UnitView[]): AreaAlert[] {
  const approved = AREA_FIELDS.find((field) => field.basis === project.costAreaBasis && field.kind === "approved");
  const built = AREA_FIELDS.find((field) => field.basis === project.costAreaBasis && field.kind === "built");
  if (!approved || !built) return [];
  const name = basisLabel(project.costAreaBasis);
  const alerts: AreaAlert[] = [];
  for (const unit of units) {
    if (unit.removed) continue;
    const result = builtVersusApproved({
      approvedSqft: unit.areas[approved.key],
      builtSqft: unit.areas[built.key],
      alertPercent: project.areaVarianceAlertPercent.toString(),
    });
    if (!result.exceeds) continue;
    const sentence =
      result.percent == null
        ? `Flat ${unit.flatNumber} has ${result.differenceSqft} sqft of ${name} area built, and no approved area to compare.`
        : `Flat ${unit.flatNumber} is ${result.differenceSqft} sqft away from the approved ${name} area (${result.percent}%). This project warns above ${project.areaVarianceAlertPercent.toString()}%.`;
    alerts.push({ unitId: unit.id, flatNumber: unit.flatNumber, sentence });
  }
  return alerts;
}

function nextStep(detail: { phases: unknown[]; towers: Array<{ floors: Array<{ units: unknown[] }> }> }): string {
  if (detail.phases.length === 0) return "Name the first phase. Most projects start with Phase 1.";
  if (detail.towers.length === 0) return "Add a tower, such as Tower A.";
  const floors = detail.towers.reduce((sum, tower) => sum + tower.floors.length, 0);
  if (floors === 0) return "Add a floor. Use 0 for the ground floor.";
  const units = detail.towers.reduce(
    (sum, tower) => sum + tower.floors.reduce((inner, floor) => inner + floor.units.length, 0),
    0,
  );
  if (units === 0) return "Add the first flat. The flat number is what the site calls it.";
  return "When the site measures a flat, record the area that was actually built.";
}

function toDetail(project: ProjectRow): ProjectDetail {
  const towers = project.towers.map((tower) => ({
    id: tower.id,
    name: tower.name,
    floors: tower.floors.map((floor) => ({
      id: floor.id,
      label: floor.label,
      levelNumber: floor.levelNumber,
      units: floor.units.map((unit) => unitView(unit)),
    })),
  }));
  const detail: ProjectDetail = {
    id: project.id,
    code: project.code,
    name: project.name,
    city: project.city,
    status: project.status,
    costAreaBasis: project.costAreaBasis,
    basisName: basisLabel(project.costAreaBasis),
    alertPercent: project.areaVarianceAlertPercent.toString(),
    nextStep: "",
    phases: project.phases.map((phase) => ({ id: phase.id, name: phase.name })),
    towers,
    alerts: [],
  };
  const units = towers.flatMap((tower) => tower.floors.flatMap((floor) => floor.units));
  detail.alerts = alertsFor(project, units);
  detail.nextStep = nextStep(detail);
  return detail;
}

export async function listProjects(ctx: TenantContext) {
  return withTenant(ctx, async (tx) => {
    const allowed = await visibleProjectIds(tx, ctx);
    const rows = await tx.project.findMany({
      where: {
        deletedAt: ctx.role === "AUDITOR" ? undefined : null,
        ...(allowed ? { id: { in: allowed } } : {}),
      },
      orderBy: { name: "asc" },
      include: {
        _count: { select: { units: { where: { deletedAt: null } }, towers: { where: { deletedAt: null } } } },
      },
    });
    return rows.map((row) => ({
      id: row.id,
      code: row.code,
      name: row.name,
      city: row.city,
      status: row.status,
      towers: row._count.towers,
      flats: row._count.units,
      removed: row.deletedAt != null,
    }));
  });
}

export async function getProject(ctx: TenantContext, projectId: string): Promise<ProjectDetail> {
  return withTenant(ctx, async (tx) => {
    await assertCanSeeProject(tx, ctx, projectId);
    const project = await tx.project.findFirst({
      where: { id: projectId, deletedAt: ctx.role === "AUDITOR" ? undefined : null },
      include: projectInclude,
    });
    if (!project) throw new AccessError("that project is not in this firm", "TENANT");
    return toDetail(project);
  });
}

export async function createProject(
  ctx: TenantContext,
  input: { code: string; name: string; city: string; stateCode: string },
) {
  assertStructure(ctx.role);
  const code = input.code.trim().toUpperCase();
  const name = input.name.trim();
  if (!/^[A-Z0-9-]{2,12}$/.test(code)) {
    throw new AccessError("use a short project code, such as SAFFRON", "FORBIDDEN");
  }
  if (name.length < 3) throw new AccessError("the project needs a name", "FORBIDDEN");
  return withTenant(ctx, (tx) =>
    tx.project.create({
      data: {
        organizationId: ctx.organizationId,
        code,
        name,
        city: input.city.trim() || null,
        stateCode: input.stateCode.trim(),
        createdById: ctx.userId,
      },
    }),
  );
}

export async function addPhase(ctx: TenantContext, projectId: string, name: string) {
  assertStructure(ctx.role);
  const trimmed = name.trim();
  if (trimmed.length < 2) throw new AccessError("the phase needs a name", "FORBIDDEN");
  return withTenant(ctx, async (tx) => {
    await assertCanSeeProject(tx, ctx, projectId);
    const last = await tx.projectPhase.findFirst({
      where: { projectId, deletedAt: null },
      orderBy: { sortOrder: "desc" },
    });
    return tx.projectPhase.create({
      data: {
        organizationId: ctx.organizationId,
        projectId,
        name: trimmed,
        sortOrder: (last?.sortOrder ?? 0) + 1,
      },
    });
  });
}

export async function addTower(ctx: TenantContext, projectId: string, name: string, phaseId: string) {
  assertStructure(ctx.role);
  const trimmed = name.trim();
  if (trimmed.length < 1) throw new AccessError("the tower needs a name", "FORBIDDEN");
  return withTenant(ctx, async (tx) => {
    await assertCanSeeProject(tx, ctx, projectId);
    return tx.tower.create({
      data: {
        organizationId: ctx.organizationId,
        projectId,
        phaseId,
        name: trimmed,
      },
    });
  });
}

export async function addFloor(ctx: TenantContext, projectId: string, towerId: string, levelNumber: number, label: string) {
  assertStructure(ctx.role);
  if (!Number.isInteger(levelNumber) || levelNumber < -5 || levelNumber > 200) {
    throw new AccessError("use a floor number such as 0 for ground", "FORBIDDEN");
  }
  return withTenant(ctx, async (tx) => {
    await assertCanSeeProject(tx, ctx, projectId);
    return tx.floor.create({
      data: {
        organizationId: ctx.organizationId,
        projectId,
        towerId,
        levelNumber,
        label: label.trim() || (levelNumber === 0 ? "Ground" : `Floor ${levelNumber}`),
      },
    });
  });
}

export type NewUnitInput = {
  projectId: string;
  floorId: string;
  flatNumber: string;
  facing: UnitFacing | "";
  areas: Partial<Record<(typeof AREA_FIELDS)[number]["key"], string>>;
};

export async function addUnit(ctx: TenantContext, input: NewUnitInput) {
  if (!canChangeStructure(ctx.role) && !canChangeBuiltArea(ctx.role)) {
    throw new AccessError(`${ctx.role} cannot add a flat`, "FORBIDDEN");
  }
  const flatNumber = input.flatNumber.trim().toUpperCase();
  if (flatNumber.length < 1) throw new AccessError("the flat needs a number", "FORBIDDEN");
  const submitted = readAreas(input.areas, ctx.role, true);
  return withTenant(ctx, async (tx) => {
    await assertCanSeeProject(tx, ctx, input.projectId);
    const floor = await tx.floor.findFirst({
      where: { id: input.floorId, projectId: input.projectId, deletedAt: null },
    });
    if (!floor) throw new AccessError("choose a floor in this project", "TENANT");
    const duplicate = await tx.unit.findFirst({
      where: { projectId: input.projectId, flatNumber, deletedAt: null },
    });
    if (duplicate) throw new AccessError(`flat ${flatNumber} is already on this project`, "FORBIDDEN");
    const unit = await tx.unit.create({
      data: {
        organizationId: ctx.organizationId,
        projectId: input.projectId,
        towerId: floor.towerId,
        floorId: floor.id,
        flatNumber,
        facing: input.facing || null,
        createdById: ctx.userId,
        ...submitted,
      },
    });
    const changes = AREA_FIELDS.flatMap((field) => {
      const next = submitted[field.key];
      if (!next || next === "0.000") return [];
      return [{ field: field.field, previous: "0.000", next }];
    });
    await writeRevisions(tx, ctx, unit.id, input.projectId, changes, "Opening measurement");
    return unit;
  });
}

export async function recordAreas(
  ctx: TenantContext,
  input: { unitId: string; reason: string; areas: Partial<Record<(typeof AREA_FIELDS)[number]["key"], string>> },
) {
  const reason = input.reason.trim();
  if (reason.length < 8) throw new AccessError("write why the area changed", "FORBIDDEN");
  return withTenant(ctx, async (tx) => {
    const current = await tx.unit.findFirst({ where: { id: input.unitId, deletedAt: null } });
    if (!current) throw new AccessError("that flat is not in this firm", "TENANT");
    await assertCanSeeProject(tx, ctx, current.projectId);
    const submitted = readAreas(input.areas, ctx.role, false);
    const changes = AREA_FIELDS.flatMap((field) => {
      const next = submitted[field.key];
      if (!next) return [];
      const previous = formatSqft(current[field.key].toString());
      if (previous === next) return [];
      return [{ field: field.field, key: field.key, previous, next }];
    });
    if (changes.length === 0) return current;
    const data: Record<string, string> = {};
    for (const change of changes) data[change.key] = change.next;
    const unit = await tx.unit.update({
      where: { id: current.id },
      data: { ...data, updatedById: ctx.userId },
    });
    await writeRevisions(tx, ctx, current.id, current.projectId, changes, reason);
    return unit;
  });
}

function readAreas(
  areas: Partial<Record<(typeof AREA_FIELDS)[number]["key"], string>>,
  role: MembershipRole,
  opening: boolean,
): Partial<Record<(typeof AREA_FIELDS)[number]["key"], string>> {
  const values: Partial<Record<(typeof AREA_FIELDS)[number]["key"], string>> = {};
  for (const field of AREA_FIELDS) {
    const raw = areas[field.key];
    if (raw == null || raw.trim() === "") continue;
    if (field.kind === "built") assertBuilt(role);
    else if (!opening || !canChangeStructure(role)) {
      if (!canChangeStructure(role)) {
        throw new AccessError(
          "the site records the built area. Planned and approved areas stay with the office.",
          "FORBIDDEN",
        );
      }
      assertStructure(role);
    }
    values[field.key] = formatSqft(parseSqft(raw));
  }
  return values;
}

async function writeRevisions(
  tx: AppTx,
  ctx: TenantContext,
  unitId: string,
  projectId: string,
  changes: Array<{ field: (typeof AREA_FIELDS)[number]["field"]; previous: string; next: string }>,
  reason: string,
) {
  for (const change of changes) {
    if (change.previous === change.next) continue;
    await tx.unitAreaRevision.create({
      data: {
        organizationId: ctx.organizationId,
        projectId,
        unitId,
        field: change.field,
        previousSqft: change.previous,
        newSqft: change.next,
        reason,
        recordedById: ctx.userId,
      },
    });
  }
}
