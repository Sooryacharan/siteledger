import type { MembershipRole, PeriodStatus } from "@prisma/client";

import { AccessError } from "./errors";

export type PeriodMove = "SOFT_CLOSE" | "LOCK" | "REOPEN";

export function nextPeriodStatus(
  current: PeriodStatus,
  move: PeriodMove,
  role: MembershipRole,
): PeriodStatus {
  if (move === "SOFT_CLOSE") {
    if (current !== "OPEN") {
      throw new AccessError("only an open period can be soft-closed", "PERIOD");
    }
    return "SOFT_CLOSED";
  }
  if (move === "LOCK") {
    if (current !== "SOFT_CLOSED") {
      throw new AccessError("only a soft-closed period can be locked", "PERIOD");
    }
    return "LOCKED";
  }
  if (current !== "LOCKED") {
    throw new AccessError("only a locked period can be reopened", "PERIOD");
  }
  if (role !== "OWNER") {
    throw new AccessError("only an owner can reopen a locked period", "PERIOD");
  }
  return "OPEN";
}
