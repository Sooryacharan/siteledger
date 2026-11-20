import Link from "next/link";

import { Button } from "@/components/ui/button";
import { Input } from "@/components/ui/input";
import { Label } from "@/components/ui/label";
import { OfficeFrame } from "@/components/office-frame";
import { requireOffice } from "@/server/office";
import { canChangeStructure, listProjects } from "@/server/projects";

import { createProjectAction } from "./actions";

export const dynamic = "force-dynamic";

const STATUS_LABEL: Record<string, string> = {
  PLANNING: "Planning",
  APPROVED: "Approved",
  IN_PROGRESS: "Being built",
  HANDED_OVER: "Handed over",
  CLOSED: "Closed",
};

export default async function ProjectsPage({
  searchParams,
}: {
  searchParams: { error?: string };
}) {
  const office = await requireOffice();
  const projects = await listProjects(office.ctx);
  const canAdd = canChangeStructure(office.ctx.role);
  return (
    <OfficeFrame
      person={office.session.user.name ?? office.session.user.email}
      firm={office.membership.organizationName}
      role={office.membership.role}
    >
      <div className="flex flex-col gap-2">
        <p className="text-xs font-medium uppercase tracking-[0.16em] text-[#8a5a2a]">Projects</p>
        <h1 className="text-3xl font-semibold tracking-tight">Buildings in this firm</h1>
        <p className="max-w-2xl text-base leading-7 text-[#3f3a33]">
          Open a project to see its towers, floors, and flats. The next step is always at the top of the project.
        </p>
      </div>

      {searchParams.error ? (
        <p className="rounded-2xl border border-[#e2b4a0] bg-white px-4 py-3 text-sm leading-6 text-[#6b2d1a]">
          {searchParams.error}
        </p>
      ) : null}

      {projects.length === 0 ? (
        <p className="rounded-2xl bg-white p-5 text-[15px] leading-6">
          {canAdd
            ? "No projects yet. Add the first one below. A short code such as SAFFRON is enough."
            : "No projects are assigned to you yet. Ask the owner to add you to a project."}
        </p>
      ) : (
        <ul className="grid gap-3 sm:grid-cols-2">
          {projects.map((project) => (
            <li key={project.id}>
              <Link
                href={`/projects/${project.id}`}
                className="flex min-h-24 flex-col justify-between rounded-2xl border border-[#e2d8c6] bg-white p-4 hover:border-[#8a5a2a]"
              >
                <span className="text-lg font-semibold">
                  {project.name}
                  {project.removed ? " · removed" : ""}
                </span>
                <span className="text-sm text-[#3f3a33]">
                  {project.code}
                  {project.city ? ` · ${project.city}` : ""} · {STATUS_LABEL[project.status] ?? project.status} ·{" "}
                  {project.towers} towers · {project.flats} flats
                </span>
              </Link>
            </li>
          ))}
        </ul>
      )}

      {canAdd ? (
        <form action={createProjectAction} className="grid gap-3 rounded-2xl bg-white p-5 sm:grid-cols-2">
          <div className="sm:col-span-2">
            <h2 className="text-lg font-semibold">Add a project</h2>
          </div>
          <div className="flex flex-col gap-2">
            <Label htmlFor="name">Project name</Label>
            <Input id="name" name="name" required placeholder="Saffron Heights" />
          </div>
          <div className="flex flex-col gap-2">
            <Label htmlFor="code">Short code</Label>
            <Input id="code" name="code" required placeholder="SAFFRON" />
          </div>
          <div className="flex flex-col gap-2">
            <Label htmlFor="city">City</Label>
            <Input id="city" name="city" placeholder="Hyderabad" />
          </div>
          <div className="flex flex-col gap-2">
            <Label htmlFor="stateCode">State code</Label>
            <Input id="stateCode" name="stateCode" required defaultValue="36" />
          </div>
          <div className="sm:col-span-2">
            <Button type="submit" size="large">
              Save the project
            </Button>
          </div>
        </form>
      ) : null}
    </OfficeFrame>
  );
}
