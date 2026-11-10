"use server";

import { redirect } from "next/navigation";

import type { UnitFacing } from "@prisma/client";

import { AREA_FIELDS } from "@/lib/area/variance";
import { AccessError } from "@/server/errors";
import { requireOffice } from "@/server/office";
import { addFloor, addPhase, addTower, addUnit, createProject, recordAreas } from "@/server/projects";

function fail(path: string, error: unknown): never {
  const message = error instanceof Error ? error.message : "That did not save";
  const code = error instanceof AccessError ? error.code : "";
  redirect(`${path}?error=${encodeURIComponent(message)}&code=${code}`);
}

export async function createProjectAction(formData: FormData) {
  const office = await requireOffice();
  try {
    const project = await createProject(office.ctx, {
      code: String(formData.get("code") ?? ""),
      name: String(formData.get("name") ?? ""),
      city: String(formData.get("city") ?? ""),
      stateCode: String(formData.get("stateCode") ?? "36"),
    });
    redirect(`/projects/${project.id}`);
  } catch (error) {
    if (isNextRedirect(error)) throw error;
    fail("/projects", error);
  }
}

export async function addPhaseAction(formData: FormData) {
  const projectId = String(formData.get("projectId") ?? "");
  const office = await requireOffice();
  try {
    await addPhase(office.ctx, projectId, String(formData.get("name") ?? ""));
  } catch (error) {
    if (isNextRedirect(error)) throw error;
    fail(`/projects/${projectId}`, error);
  }
  redirect(`/projects/${projectId}`);
}

export async function addTowerAction(formData: FormData) {
  const projectId = String(formData.get("projectId") ?? "");
  const office = await requireOffice();
  try {
    await addTower(
      office.ctx,
      projectId,
      String(formData.get("name") ?? ""),
      String(formData.get("phaseId") ?? ""),
    );
  } catch (error) {
    if (isNextRedirect(error)) throw error;
    fail(`/projects/${projectId}`, error);
  }
  redirect(`/projects/${projectId}`);
}

export async function addFloorAction(formData: FormData) {
  const projectId = String(formData.get("projectId") ?? "");
  const office = await requireOffice();
  try {
    await addFloor(
      office.ctx,
      projectId,
      String(formData.get("towerId") ?? ""),
      Number(formData.get("levelNumber")),
      String(formData.get("label") ?? ""),
    );
  } catch (error) {
    if (isNextRedirect(error)) throw error;
    fail(`/projects/${projectId}`, error);
  }
  redirect(`/projects/${projectId}`);
}

export async function addUnitAction(formData: FormData) {
  const projectId = String(formData.get("projectId") ?? "");
  const office = await requireOffice();
  const areas: Partial<Record<(typeof AREA_FIELDS)[number]["key"], string>> = {};
  for (const field of AREA_FIELDS) {
    areas[field.key] = String(formData.get(field.key) ?? "");
  }
  try {
    await addUnit(office.ctx, {
      projectId,
      floorId: String(formData.get("floorId") ?? ""),
      flatNumber: String(formData.get("flatNumber") ?? ""),
      facing: String(formData.get("facing") ?? "") as UnitFacing | "",
      areas,
    });
  } catch (error) {
    if (isNextRedirect(error)) throw error;
    fail(`/projects/${projectId}`, error);
  }
  redirect(`/projects/${projectId}`);
}

export async function recordBuiltAreaAction(formData: FormData) {
  const projectId = String(formData.get("projectId") ?? "");
  const office = await requireOffice();
  const key = String(formData.get("areaKey") ?? "") as (typeof AREA_FIELDS)[number]["key"];
  try {
    await recordAreas(office.ctx, {
      unitId: String(formData.get("unitId") ?? ""),
      reason: String(formData.get("reason") ?? ""),
      areas: { [key]: String(formData.get("sqft") ?? "") },
    });
  } catch (error) {
    if (isNextRedirect(error)) throw error;
    fail(`/projects/${projectId}`, error);
  }
  redirect(`/projects/${projectId}`);
}

function isNextRedirect(error: unknown): boolean {
  return (
    typeof error === "object" &&
    error !== null &&
    "digest" in error &&
    String((error as { digest: unknown }).digest).startsWith("NEXT_REDIRECT")
  );
}
