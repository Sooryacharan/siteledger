import Link from "next/link";

import { Button } from "@/components/ui/button";
import { Input } from "@/components/ui/input";
import { Label } from "@/components/ui/label";
import { OfficeFrame } from "@/components/office-frame";
import { AREA_FIELDS, basisLabel } from "@/lib/area/variance";
import { requireOffice } from "@/server/office";
import { canChangeBuiltArea, canChangeStructure, getProject, type UnitView } from "@/server/projects";

import { addFloorAction, addPhaseAction, addTowerAction, addUnitAction, recordBuiltAreaAction } from "../actions";

export const dynamic = "force-dynamic";

const FACING = [
  ["", "Facing not set"],
  ["NORTH", "North"],
  ["SOUTH", "South"],
  ["EAST", "East"],
  ["WEST", "West"],
  ["NORTH_EAST", "North-east"],
  ["NORTH_WEST", "North-west"],
  ["SOUTH_EAST", "South-east"],
  ["SOUTH_WEST", "South-west"],
] as const;

function facingLabel(value: string | null): string {
  return FACING.find((item) => item[0] === (value ?? ""))?.[1] ?? "Facing not set";
}

function Field({ name, label, defaultValue = "" }: { name: string; label: string; defaultValue?: string }) {
  return (
    <div className="flex flex-col gap-2">
      <Label htmlFor={name}>{label}</Label>
      <Input id={name} name={name} inputMode="decimal" defaultValue={defaultValue} placeholder="0" />
    </div>
  );
}

function UnitCard({
  projectId,
  unit,
  basis,
  canBuild,
  areaKey,
}: {
  projectId: string;
  unit: UnitView;
  basis: string;
  canBuild: boolean;
  areaKey: (typeof AREA_FIELDS)[number]["key"];
}) {
  const planned = AREA_FIELDS.find((field) => field.basis === basis && field.kind === "planned");
  const approved = AREA_FIELDS.find((field) => field.basis === basis && field.kind === "approved");
  const built = AREA_FIELDS.find((field) => field.basis === basis && field.kind === "built");
  return (
    <article className="rounded-2xl border border-[#e2d8c6] bg-[#f7f1e6] p-4">
      <h3 className="text-lg font-semibold">Flat {unit.flatNumber}</h3>
      <p className="mt-1 text-sm text-[#3f3a33]">{facingLabel(unit.facing)}</p>
      {planned && approved && built ? (
        <p className="mt-2 text-sm leading-6">
          {basisLabel(basis as "CARPET" | "BUILT_UP" | "SUPER_BUILT_UP")}: planned {unit.areas[planned.key]} sqft ·
          approved {unit.areas[approved.key]} sqft · built {unit.areas[built.key]} sqft
        </p>
      ) : null}
      {canBuild && built ? (
        <form action={recordBuiltAreaAction} className="mt-3 grid gap-2 sm:grid-cols-[1fr_1.4fr_auto]">
          <input type="hidden" name="projectId" value={projectId} />
          <input type="hidden" name="unitId" value={unit.id} />
          <input type="hidden" name="areaKey" value={areaKey} />
          <Input name="sqft" inputMode="decimal" aria-label={`Built area for flat ${unit.flatNumber}`} placeholder="Built sqft" required />
          <Input name="reason" aria-label={`Reason for flat ${unit.flatNumber}`} placeholder="Why the area changed" required />
          <Button type="submit">Save built area</Button>
        </form>
      ) : null}
    </article>
  );
}

export default async function ProjectPage({
  params,
  searchParams,
}: {
  params: { projectId: string };
  searchParams: { error?: string };
}) {
  const office = await requireOffice();
  const project = await getProject(office.ctx, params.projectId);
  const structure = canChangeStructure(office.ctx.role);
  const site = canChangeBuiltArea(office.ctx.role);
  const builtField = AREA_FIELDS.find((field) => field.basis === project.costAreaBasis && field.kind === "built");
  const floors = project.towers.flatMap((tower) => tower.floors.map((floor) => ({ ...floor, towerName: tower.name })));
  return (
    <OfficeFrame
      person={office.session.user.name ?? office.session.user.email}
      firm={office.membership.organizationName}
      role={office.membership.role}
    >
      <div className="flex flex-col gap-2">
        <Link href="/projects" className="text-sm text-[#8a5a2a]">
          All projects
        </Link>
        <h1 className="text-3xl font-semibold tracking-tight">{project.name}</h1>
        <p className="text-base text-[#3f3a33]">
          {project.code}
          {project.city ? ` · ${project.city}` : ""} · cost area is {project.basisName}. A difference above{" "}
          {project.alertPercent}% is flagged.
        </p>
      </div>

      <p className="rounded-2xl bg-[#1c1915] px-4 py-4 text-[#f3efe4]">
        <span className="text-xs uppercase tracking-[0.14em] text-[#d7b089]">What to do next</span>
        <span className="mt-1 block text-base leading-7">
          {site
            ? project.nextStep
            : "You can look through the flats. Changing the building or the built area is for the office and the site."}
        </span>
      </p>

      {searchParams.error ? (
        <p className="rounded-2xl border border-[#e2b4a0] bg-white px-4 py-3 text-sm leading-6 text-[#6b2d1a]">
          {searchParams.error}
        </p>
      ) : null}

      {project.alerts.length > 0 ? (
        <section className="rounded-2xl border border-[#e2b4a0] bg-white p-5">
          <h2 className="text-lg font-semibold">Area to check</h2>
          <ul className="mt-3 flex flex-col gap-2">
            {project.alerts.map((alert) => (
              <li key={alert.unitId} className="text-sm leading-6">
                {alert.sentence}
              </li>
            ))}
          </ul>
        </section>
      ) : null}

      {structure && project.phases.length === 0 ? (
        <form action={addPhaseAction} className="grid gap-3 rounded-2xl bg-white p-5 sm:grid-cols-[1fr_auto]">
          <input type="hidden" name="projectId" value={project.id} />
          <div className="flex flex-col gap-2">
            <Label htmlFor="phase">Phase name</Label>
            <Input id="phase" name="name" required placeholder="Phase 1" />
          </div>
          <Button type="submit" className="self-end">
            Add the phase
          </Button>
        </form>
      ) : null}

      {structure && project.phases.length > 0 && project.towers.length === 0 ? (
        <form action={addTowerAction} className="grid gap-3 rounded-2xl bg-white p-5 sm:grid-cols-[1fr_auto]">
          <input type="hidden" name="projectId" value={project.id} />
          <input type="hidden" name="phaseId" value={project.phases[0]?.id} />
          <div className="flex flex-col gap-2">
            <Label htmlFor="tower">Tower name</Label>
            <Input id="tower" name="name" required placeholder="Tower A" />
          </div>
          <Button type="submit" className="self-end">
            Add the tower
          </Button>
        </form>
      ) : null}

      {structure && project.towers.length > 0 && floors.length === 0 ? (
        <form action={addFloorAction} className="grid gap-3 rounded-2xl bg-white p-5 sm:grid-cols-3">
          <input type="hidden" name="projectId" value={project.id} />
          <input type="hidden" name="towerId" value={project.towers[0]?.id} />
          <div className="flex flex-col gap-2">
            <Label htmlFor="level">Floor number</Label>
            <Input id="level" name="levelNumber" inputMode="numeric" required defaultValue="0" />
          </div>
          <div className="flex flex-col gap-2">
            <Label htmlFor="floorLabel">Name on site</Label>
            <Input id="floorLabel" name="label" placeholder="Ground" />
          </div>
          <Button type="submit" className="self-end">
            Add the floor
          </Button>
        </form>
      ) : null}

      {floors.length > 0 && (structure || site) ? (
        <form action={addUnitAction} className="grid gap-3 rounded-2xl bg-white p-5">
          <h2 className="text-lg font-semibold">Add a flat</h2>
          <input type="hidden" name="projectId" value={project.id} />
          <div className="grid gap-3 sm:grid-cols-3">
            <div className="flex flex-col gap-2">
              <Label htmlFor="flatNumber">Flat number</Label>
              <Input id="flatNumber" name="flatNumber" required placeholder="A-101" />
            </div>
            <div className="flex flex-col gap-2">
              <Label htmlFor="floorId">Floor</Label>
              <select id="floorId" name="floorId" className="min-h-11 rounded-xl border border-[#e2d8c6] bg-white px-3">
                {floors.map((floor) => (
                  <option key={floor.id} value={floor.id}>
                    {floor.towerName} · {floor.label}
                  </option>
                ))}
              </select>
            </div>
            <div className="flex flex-col gap-2">
              <Label htmlFor="facing">Facing</Label>
              <select id="facing" name="facing" className="min-h-11 rounded-xl border border-[#e2d8c6] bg-white px-3">
                {FACING.map(([value, label]) => (
                  <option key={value || "none"} value={value}>
                    {label}
                  </option>
                ))}
              </select>
            </div>
          </div>
          <div className="grid gap-3 sm:grid-cols-3">
            {AREA_FIELDS.filter((field) => field.basis === project.costAreaBasis).map((field) => (
              <Field key={field.key} name={field.key} label={`${field.label} (sqft)`} />
            ))}
          </div>
          {structure ? (
            <details className="text-sm">
              <summary className="cursor-pointer text-[#8a5a2a]">Also record carpet and built-up</summary>
              <div className="mt-3 grid gap-3 sm:grid-cols-3">
                {AREA_FIELDS.filter((field) => field.basis !== project.costAreaBasis).map((field) => (
                  <Field key={field.key} name={field.key} label={`${field.label} (sqft)`} />
                ))}
              </div>
            </details>
          ) : null}
          <Button type="submit" size="large">
            Save the flat
          </Button>
        </form>
      ) : null}

      <section className="flex flex-col gap-6">
        {project.towers.map((tower) => (
          <div key={tower.id} className="flex flex-col gap-3">
            <h2 className="text-xl font-semibold">{tower.name}</h2>
            {tower.floors.map((floor) => (
              <div key={floor.id} className="flex flex-col gap-3">
                <h3 className="text-sm font-medium uppercase tracking-[0.12em] text-[#6b645b]">
                  {floor.label} · level {floor.levelNumber}
                </h3>
                {floor.units.length === 0 ? (
                  <p className="text-sm text-[#3f3a33]">No flats on this floor yet.</p>
                ) : (
                  floor.units.map((unit) => (
                    <UnitCard
                      key={unit.id}
                      projectId={project.id}
                      unit={unit}
                      basis={project.costAreaBasis}
                      canBuild={site}
                      areaKey={builtField?.key ?? "superBuiltUpBuiltSqft"}
                    />
                  ))
                )}
              </div>
            ))}
          </div>
        ))}
      </section>

      {structure && project.phases.length > 0 && project.towers.length > 0 ? (
        <form action={addTowerAction} className="grid gap-3 rounded-2xl border border-[#e2d8c6] bg-white p-5 sm:grid-cols-[1fr_auto]">
          <input type="hidden" name="projectId" value={project.id} />
          <input type="hidden" name="phaseId" value={project.phases[0]?.id} />
          <div className="flex flex-col gap-2">
            <Label htmlFor="anotherTower">Another tower</Label>
            <Input id="anotherTower" name="name" placeholder="Tower B" />
          </div>
          <Button type="submit" variant="outline" className="self-end">
            Add tower
          </Button>
        </form>
      ) : null}
    </OfficeFrame>
  );
}
