import Decimal from "decimal.js";

import type { CostAreaBasis, UnitAreaField } from "@prisma/client";

Decimal.set({ precision: 40, rounding: Decimal.ROUND_HALF_UP });

const SQFT = /^\d+(\.\d{1,3})?$/;

export const AREA_FIELDS: Array<{
  field: UnitAreaField;
  key:
    | "carpetPlannedSqft"
    | "carpetApprovedSqft"
    | "carpetBuiltSqft"
    | "builtUpPlannedSqft"
    | "builtUpApprovedSqft"
    | "builtUpBuiltSqft"
    | "superBuiltUpPlannedSqft"
    | "superBuiltUpApprovedSqft"
    | "superBuiltUpBuiltSqft";
  label: string;
  basis: CostAreaBasis;
  kind: "planned" | "approved" | "built";
}> = [
  { field: "CARPET_PLANNED", key: "carpetPlannedSqft", label: "Carpet, as planned", basis: "CARPET", kind: "planned" },
  { field: "CARPET_APPROVED", key: "carpetApprovedSqft", label: "Carpet, as approved", basis: "CARPET", kind: "approved" },
  { field: "CARPET_BUILT", key: "carpetBuiltSqft", label: "Carpet, as actually built", basis: "CARPET", kind: "built" },
  { field: "BUILT_UP_PLANNED", key: "builtUpPlannedSqft", label: "Built-up, as planned", basis: "BUILT_UP", kind: "planned" },
  { field: "BUILT_UP_APPROVED", key: "builtUpApprovedSqft", label: "Built-up, as approved", basis: "BUILT_UP", kind: "approved" },
  { field: "BUILT_UP_BUILT", key: "builtUpBuiltSqft", label: "Built-up, as actually built", basis: "BUILT_UP", kind: "built" },
  { field: "SUPER_BUILT_UP_PLANNED", key: "superBuiltUpPlannedSqft", label: "Super built-up, as planned", basis: "SUPER_BUILT_UP", kind: "planned" },
  { field: "SUPER_BUILT_UP_APPROVED", key: "superBuiltUpApprovedSqft", label: "Super built-up, as approved", basis: "SUPER_BUILT_UP", kind: "approved" },
  { field: "SUPER_BUILT_UP_BUILT", key: "superBuiltUpBuiltSqft", label: "Super built-up, as actually built", basis: "SUPER_BUILT_UP", kind: "built" },
];

export function parseSqft(input: string): Decimal {
  const value = input.trim();
  if (!SQFT.test(value)) {
    throw new Error("Area must be a number of square feet, with at most 3 decimal places.");
  }
  return new Decimal(value);
}

export function formatSqft(value: Decimal | string): string {
  return new Decimal(value.toString()).toDecimalPlaces(3, Decimal.ROUND_HALF_UP).toFixed(3);
}

export type AreaVariance = {
  differenceSqft: string;
  /** Null when the approved area is zero, so there is no percentage to show. */
  percent: string | null;
  exceeds: boolean;
};

/**
 * Built versus approved, on one area basis.
 * Equal to the project's alert percent is not a warning. Above it is.
 * A built area with no approved area is a warning. Zero and zero is not.
 */
export function builtVersusApproved(input: {
  approvedSqft: string;
  builtSqft: string;
  alertPercent: string;
}): AreaVariance {
  const approved = new Decimal(input.approvedSqft);
  const built = new Decimal(input.builtSqft);
  const alert = new Decimal(input.alertPercent);
  const difference = built.minus(approved);
  if (approved.isZero()) {
    return {
      differenceSqft: formatSqft(difference),
      percent: null,
      exceeds: built.gt(0),
    };
  }
  const percent = difference.div(approved).times(100);
  return {
    differenceSqft: formatSqft(difference),
    percent: percent.toDecimalPlaces(2, Decimal.ROUND_HALF_UP).toFixed(2),
    exceeds: percent.abs().gt(alert),
  };
}

export function basisLabel(basis: CostAreaBasis): string {
  if (basis === "CARPET") return "carpet";
  if (basis === "BUILT_UP") return "built-up";
  return "super built-up";
}
