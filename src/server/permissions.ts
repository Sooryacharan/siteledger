import type { MembershipRole } from "@prisma/client";

import { AccessError } from "./errors";

/** The eight roles from the product brief, in the order the matrix is written. */
export const MEMBERSHIP_ROLES = [
  "OWNER",
  "FINANCE",
  "PROJECT_MANAGER",
  "SITE_ENGINEER",
  "SALES",
  "VENDOR",
  "CUSTOMER",
  "AUDITOR",
] as const satisfies readonly MembershipRole[];

export type Permission =
  | "read"
  | "write"
  | "export"
  | "period.reopen"
  | "approve"
  | "invoice.upload";

/**
 * What a role is allowed to reach before a query runs.
 * Project rows are narrowed again by row-level security.
 * `approve` means the role may be a checker. The amount band still decides which step.
 */
const MATRIX: Record<MembershipRole, Record<Permission, boolean>> = {
  OWNER: {
    read: true,
    write: true,
    export: true,
    "period.reopen": true,
    approve: true,
    "invoice.upload": false,
  },
  FINANCE: {
    read: true,
    write: true,
    export: true,
    "period.reopen": false,
    approve: true,
    "invoice.upload": false,
  },
  PROJECT_MANAGER: {
    read: true,
    write: true,
    export: false,
    "period.reopen": false,
    approve: false,
    "invoice.upload": false,
  },
  SITE_ENGINEER: {
    read: true,
    write: true,
    export: false,
    "period.reopen": false,
    approve: false,
    "invoice.upload": false,
  },
  SALES: {
    read: true,
    write: true,
    export: false,
    "period.reopen": false,
    approve: false,
    "invoice.upload": false,
  },
  VENDOR: {
    read: true,
    write: false,
    export: false,
    "period.reopen": false,
    approve: false,
    "invoice.upload": true,
  },
  CUSTOMER: {
    read: true,
    write: false,
    export: false,
    "period.reopen": false,
    approve: false,
    "invoice.upload": false,
  },
  AUDITOR: {
    read: true,
    write: false,
    export: true,
    "period.reopen": false,
    approve: false,
    "invoice.upload": false,
  },
};

export type Visibility = "firm" | "assigned-projects" | "own-party";

const VISIBILITY: Record<MembershipRole, Visibility> = {
  OWNER: "firm",
  FINANCE: "firm",
  AUDITOR: "firm",
  PROJECT_MANAGER: "assigned-projects",
  SITE_ENGINEER: "assigned-projects",
  SALES: "assigned-projects",
  VENDOR: "own-party",
  CUSTOMER: "own-party",
};

export function can(role: MembershipRole, permission: Permission): boolean {
  return MATRIX[role][permission];
}

export function visibilityFor(role: MembershipRole): Visibility {
  return VISIBILITY[role];
}

export function assertCan(role: MembershipRole, permission: Permission): void {
  if (!can(role, permission)) {
    throw new AccessError(`${role} cannot ${permission}`, "FORBIDDEN");
  }
}

/** Owner, finance, and auditor see the whole firm. The other roles do not. */
export function seesWholeFirm(role: MembershipRole): boolean {
  return visibilityFor(role) === "firm";
}
