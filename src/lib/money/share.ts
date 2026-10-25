import Decimal from "decimal.js";

import { simpleInterestPaise } from "./formulas";
import { halfUpPaise, paiseDecimal, parsePercent } from "./rounding";

export type ShareEntryType = "HURDLE" | "PROFIT" | "LOSS" | "FIXED";

export type ShareRule = {
  partnerPartyId: string;
  priority: number;
  sharePercent: string | null;
  hurdleRatePercent: string | null;
  fixedAmountPaise: bigint | null;
  isResidual: boolean;
  participatesInLoss: boolean;
  absorbsRounding: boolean;
};

export type ContributionSpan = {
  partnerPartyId: string;
  amountPaise: bigint;
  dayCount: number;
};

export type AreaAllocation = {
  partnerPartyId: string;
  areaSqft: string;
};

export type ShareEntry = {
  partnerPartyId: string;
  entryType: ShareEntryType;
  amountPaise: bigint;
};

/**
 * Profit and revenue use the same waterfall. The caller decides which figure
 * to pass as profitPaise. Saleable-area agreements cannot also carry a hurdle
 * or a fixed preference in this version.
 *
 * Positive profit:
 * 1. Hurdles, in priority order, as simple interest on each contribution span.
 * 2. Fixed preferences, in priority order, capped by what remains.
 * 3. Residual percents of what remains. They must sum to 100.
 *    Exactly one residual rule absorbs rounding.
 * A loss skips hurdles and fixed amounts. It is split by residual partners
 * who participate in losses. Their percents must also sum to 100.
 */
export function computeAgreementShare(input: {
  basis: "PROFIT" | "REVENUE" | "SALEABLE_AREA";
  profitPaise: bigint;
  rules: ShareRule[];
  contributions: ContributionSpan[];
  areas?: AreaAllocation[];
}): ShareEntry[] {
  if (input.basis === "SALEABLE_AREA") {
    if (input.rules.some((rule) => rule.hurdleRatePercent || rule.fixedAmountPaise)) {
      throw new Error(
        "A saleable-area agreement cannot also carry a hurdle or a fixed amount",
      );
    }
    return shareByArea(input.profitPaise, input.areas ?? []);
  }
  if (input.profitPaise === 0n) {
    return [];
  }
  if (input.profitPaise < 0n) {
    return allocateResidual(input.profitPaise, lossRules(input.rules), "LOSS");
  }

  let remaining = input.profitPaise;
  const entries: ShareEntry[] = [];
  const byPriority = [...input.rules].sort((a, b) => a.priority - b.priority || a.partnerPartyId.localeCompare(b.partnerPartyId));

  for (const rule of byPriority) {
    if (!rule.hurdleRatePercent) continue;
    const hurdle = hurdlePaise(rule, input.contributions);
    const pay = hurdle < remaining ? hurdle : remaining;
    if (pay > 0n) {
      entries.push({
        partnerPartyId: rule.partnerPartyId,
        entryType: "HURDLE",
        amountPaise: pay,
      });
      remaining -= pay;
    }
  }

  for (const rule of byPriority) {
    if (rule.fixedAmountPaise == null) continue;
    if (rule.fixedAmountPaise < 0n) {
      throw new Error("fixedAmountPaise cannot be negative");
    }
    const pay = rule.fixedAmountPaise < remaining ? rule.fixedAmountPaise : remaining;
    if (pay > 0n) {
      entries.push({
        partnerPartyId: rule.partnerPartyId,
        entryType: "FIXED",
        amountPaise: pay,
      });
      remaining -= pay;
    }
  }

  entries.push(...allocateResidual(remaining, input.rules.filter((rule) => rule.isResidual), "PROFIT"));
  return entries;
}

function lossRules(rules: ShareRule[]): ShareRule[] {
  return rules.filter((rule) => rule.isResidual && rule.participatesInLoss);
}

function hurdlePaise(rule: ShareRule, contributions: ContributionSpan[]): bigint {
  const spans = contributions.filter((span) => span.partnerPartyId === rule.partnerPartyId);
  return spans.reduce(
    (sum, span) =>
      sum + simpleInterestPaise(span.amountPaise, rule.hurdleRatePercent ?? "0", span.dayCount),
    0n,
  );
}

function allocateResidual(
  remaining: bigint,
  rules: ShareRule[],
  entryType: "PROFIT" | "LOSS",
): ShareEntry[] {
  if (rules.length === 0) {
    throw new Error("The agreement has no residual partners");
  }
  const percentSum = rules.reduce(
    (sum, rule) => sum.plus(parsePercent(rule.sharePercent ?? "")),
    new Decimal(0),
  );
  if (!percentSum.eq(100)) {
    throw new Error(`Residual percents must sum to 100, received ${percentSum.toFixed(4)}`);
  }
  const absorbers = rules.filter((rule) => rule.absorbsRounding);
  if (absorbers.length !== 1) {
    throw new Error("Exactly one residual partner must absorb rounding");
  }
  const others = rules
    .filter((rule) => !rule.absorbsRounding)
    .sort((a, b) => a.priority - b.priority || a.partnerPartyId.localeCompare(b.partnerPartyId));
  let used = 0n;
  const entries: ShareEntry[] = [];
  for (const rule of others) {
    const share = halfUpPaise(
      paiseDecimal(remaining).mul(parsePercent(rule.sharePercent ?? "0")).div(100),
    );
    used += share;
    if (share !== 0n) {
      entries.push({ partnerPartyId: rule.partnerPartyId, entryType, amountPaise: share });
    }
  }
  const rest = remaining - used;
  if (rest !== 0n) {
    entries.push({
      partnerPartyId: absorbers[0].partnerPartyId,
      entryType,
      amountPaise: rest,
    });
  }
  return entries;
}

/**
 * Rounding residual goes to the partner with the largest area.
 * Ties break by partner id, descending, so the result does not depend on input order.
 */
export function shareByArea(profitPaise: bigint, areas: AreaAllocation[]): ShareEntry[] {
  if (areas.length === 0) {
    throw new Error("Area allocation is empty");
  }
  const parsed = areas.map((area) => ({
    partnerPartyId: area.partnerPartyId,
    area: new Decimal(area.areaSqft),
  }));
  if (parsed.some((area) => area.area.isNeg())) {
    throw new Error("Area cannot be negative");
  }
  const total = parsed.reduce((sum, area) => sum.plus(area.area), new Decimal(0));
  if (total.lte(0)) {
    throw new Error("Allocated area is zero");
  }
  const ranked = [...parsed].sort((a, b) => {
    const byArea = b.area.comparedTo(a.area);
    if (byArea !== 0) return byArea;
    return b.partnerPartyId.localeCompare(a.partnerPartyId);
  });
  const absorberId = ranked[0].partnerPartyId;
  let used = 0n;
  const entries: ShareEntry[] = [];
  for (const area of ranked.filter((item) => item.partnerPartyId !== absorberId)) {
    const share = halfUpPaise(paiseDecimal(profitPaise).mul(area.area).div(total));
    used += share;
    if (share !== 0n) {
      entries.push({
        partnerPartyId: area.partnerPartyId,
        entryType: profitPaise < 0n ? "LOSS" : "PROFIT",
        amountPaise: share,
      });
    }
  }
  const rest = profitPaise - used;
  if (rest !== 0n) {
    entries.push({
      partnerPartyId: absorberId,
      entryType: profitPaise < 0n ? "LOSS" : "PROFIT",
      amountPaise: rest,
    });
  }
  return entries;
}
