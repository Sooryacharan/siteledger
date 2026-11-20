import { GENESIS_HASH } from "../src/lib/integrity/hash";
import { gstinCheckDigit, validateGstin } from "../src/lib/gst/gstin";
import { defaultPaymentBands } from "../src/server/approval-rules";
import { appendAudit, ownerDb } from "../src/server/db";
import { applySession, type TenantContext } from "../src/server/tenant";

const CHAINS = ["JOURNAL", "STOCK", "SHARE", "AUDIT"] as const;

type FirmSeed = {
  slug: string;
  legalName: string;
  displayName: string;
  city: string;
  stateCode: string;
  gstin: string;
  ownerEmail: string;
  ownerName: string;
};

const RED_EARTH: FirmSeed = {
  slug: "red-earth",
  legalName: "Red Earth Developers",
  displayName: "Red Earth",
  city: "Hyderabad",
  stateCode: "36",
  gstin: "36AAAAA0000A1Z3",
  ownerEmail: "ananya.rao@red-earth.example",
  ownerName: "Ananya Rao",
};

const BLUE_BASIN: FirmSeed = {
  slug: "blue-basin",
  legalName: "Blue Basin Estates",
  displayName: "Blue Basin",
  city: "Bengaluru",
  stateCode: "29",
  gstin: `29BBBBB1111B1Z${gstinCheckDigit("29BBBBB1111B1Z")}`,
  ownerEmail: "farida.banerjee@blue-basin.example",
  ownerName: "Farida Banerjee",
};

function assertGstin(gstin: string): string {
  const result = validateGstin(gstin);
  if (!result.ok) throw new Error(result.reason);
  return result.gstin;
}

async function userId(email: string, name: string): Promise<string> {
  const user = await ownerDb.user.upsert({
    where: { email },
    update: { name },
    create: { email, name, emailVerified: new Date() },
  });
  return user.id;
}

async function seedFirm(firm: FirmSeed, people: Array<{ email: string; name: string; role: "OWNER" | "FINANCE" | "PROJECT_MANAGER" | "SITE_ENGINEER" | "SALES" | "AUDITOR" | "VENDOR" | "CUSTOMER"; party?: "vendor" | "customer" }>) {
  const gstin = assertGstin(firm.gstin);
  const existing = await ownerDb.organization.findUnique({ where: { slug: firm.slug } });
  if (existing) return;

  const owner = await userId(firm.ownerEmail, firm.ownerName);
  const ids = new Map<string, string>();
  for (const person of people) {
    ids.set(person.email, await userId(person.email, person.name));
  }
  ids.set(firm.ownerEmail, owner);

  await ownerDb.$transaction(async (tx) => {
    const org = await tx.organization.create({
      data: {
        slug: firm.slug,
        legalName: firm.legalName,
        displayName: firm.displayName,
        city: firm.city,
        stateCode: firm.stateCode,
        gstin,
        gstinChecksumValid: true,
        timezone: "Asia/Kolkata",
      },
    });
    await tx.chainHead.createMany({
      data: CHAINS.map((chain) => ({
        organizationId: org.id,
        chain,
        lastHash: GENESIS_HASH,
        lastSequence: 0,
      })),
    });

    const vendor = await tx.party.create({
      data: {
        organizationId: org.id,
        kind: "COMPANY",
        legalName: firm.slug === "red-earth" ? "Kaveri Cement Traders" : "Lotus Stone Works",
        displayName: firm.slug === "red-earth" ? "Kaveri Cement" : "Lotus Stone",
        isVendor: true,
      },
    });
    const customer =
      firm.slug === "red-earth"
        ? await tx.party.create({
            data: {
              organizationId: org.id,
              kind: "INDIVIDUAL",
              legalName: "Nikhil Shetty",
              displayName: "Nikhil Shetty",
              isCustomer: true,
            },
          })
        : null;

    const ctx: TenantContext = {
      organizationId: org.id,
      userId: owner,
      role: "OWNER",
      partyId: null,
      ipAddress: null,
      userAgent: "seed",
      deviceId: null,
      requestId: "seed",
    };
    await applySession(tx, ctx);

    for (const person of people) {
      const partyId =
        person.party === "vendor" ? vendor.id : person.party === "customer" ? customer?.id : null;
      if ((person.role === "VENDOR" || person.role === "CUSTOMER") && !partyId) {
        throw new Error(`${person.role} needs a party`);
      }
      const membership = await tx.membership.create({
        data: {
          organizationId: org.id,
          userId: ids.get(person.email)!,
          role: person.role,
          partyId: partyId ?? null,
          createdById: owner,
        },
      });
      await appendAudit(tx, ctx, {
        action: "CREATE",
        entityType: "MEMBERSHIP",
        entityId: membership.id,
        before: null,
        after: { role: person.role, email: person.email },
      });
    }

    if (firm.slug === "red-earth") {
      const project = await tx.project.create({
        data: {
          organizationId: org.id,
          code: "SAFFRON",
          name: "Saffron Heights",
          city: "Hyderabad",
          stateCode: "36",
          createdById: owner,
        },
      });
      await appendAudit(tx, ctx, {
        action: "CREATE",
        entityType: "PROJECT",
        entityId: project.id,
        before: null,
        after: { code: "SAFFRON", name: "Saffron Heights" },
      });
      for (const email of [
        "leela.menon@red-earth.example",
        "imran.qureshi@red-earth.example",
        "sana.pillai@red-earth.example",
      ]) {
        const assignment = await tx.projectAssignment.create({
          data: {
            organizationId: org.id,
            projectId: project.id,
            userId: ids.get(email)!,
            createdById: owner,
          },
        });
        await appendAudit(tx, ctx, {
          action: "CREATE",
          entityType: "PROJECT_ASSIGNMENT",
          entityId: assignment.id,
          before: null,
          after: { projectId: project.id, userId: ids.get(email) },
        });
      }
    }

    const year = await tx.fiscalYear.create({
      data: {
        organizationId: org.id,
        name: "FY 2026-27",
        startsOn: new Date("2026-04-01T00:00:00.000Z"),
        endsOn: new Date("2027-03-31T00:00:00.000Z"),
      },
    });
    const period = await tx.accountingPeriod.create({
      data: {
        organizationId: org.id,
        fiscalYearId: year.id,
        name: "April 2026",
        startsOn: new Date("2026-04-01T00:00:00.000Z"),
        endsOn: new Date("2026-04-30T00:00:00.000Z"),
      },
    });
    await appendAudit(tx, ctx, {
      action: "CREATE",
      entityType: "ACCOUNTING_PERIOD",
      entityId: period.id,
      before: null,
      after: { name: "April 2026" },
    });

    for (const band of defaultPaymentBands()) {
      const policy = await tx.approvalPolicy.create({
        data: {
          organizationId: org.id,
          entityType: "PAYMENT",
          minAmountPaise: band.minAmountPaise,
          maxAmountPaise: band.maxAmountPaise,
          stepOrder: band.stepOrder,
          approverRole: band.approverRole,
          autoApprove: band.autoApprove,
          plainLanguage: band.plainLanguage,
          createdById: owner,
        },
      });
      await appendAudit(tx, ctx, {
        action: "CREATE",
        entityType: "APPROVAL_POLICY",
        entityId: policy.id,
        before: null,
        after: { plainLanguage: band.plainLanguage, stepOrder: band.stepOrder },
      });
    }

    await appendAudit(tx, ctx, {
      action: "CREATE",
      entityType: "PARTY",
      entityId: vendor.id,
      before: null,
      after: { displayName: vendor.displayName },
    });
    if (customer) {
      await appendAudit(tx, ctx, {
        action: "CREATE",
        entityType: "PARTY",
        entityId: customer.id,
        before: null,
        after: { displayName: customer.displayName },
      });
    }
  });
}

async function ensureBuildings(): Promise<void> {
  const red = await ownerDb.organization.findUnique({ where: { slug: "red-earth" } });
  const owner = await ownerDb.user.findUnique({ where: { email: RED_EARTH.ownerEmail } });
  if (!red || !owner) return;
  const project = await ownerDb.project.findFirst({
    where: { organizationId: red.id, code: "SAFFRON", deletedAt: null },
  });
  if (!project) return;
  const existing = await ownerDb.unit.count({ where: { projectId: project.id, deletedAt: null } });
  if (existing > 0) return;

  await ownerDb.$transaction(async (tx) => {
    const phase = await tx.projectPhase.create({
      data: { organizationId: red.id, projectId: project.id, name: "Phase 1", sortOrder: 1 },
    });
    const tower = await tx.tower.create({
      data: { organizationId: red.id, projectId: project.id, phaseId: phase.id, name: "Tower A" },
    });
    const ground = await tx.floor.create({
      data: {
        organizationId: red.id,
        projectId: project.id,
        towerId: tower.id,
        levelNumber: 0,
        label: "Ground",
      },
    });
    const first = await tx.floor.create({
      data: {
        organizationId: red.id,
        projectId: project.id,
        towerId: tower.id,
        levelNumber: 1,
        label: "First floor",
      },
    });
    const groundFlat = await tx.unit.create({
      data: {
        organizationId: red.id,
        projectId: project.id,
        towerId: tower.id,
        floorId: ground.id,
        flatNumber: "A-G01",
        facing: "EAST",
        createdById: owner.id,
        carpetPlannedSqft: "980.000",
        carpetApprovedSqft: "980.000",
        carpetBuiltSqft: "980.000",
        superBuiltUpPlannedSqft: "1450.000",
        superBuiltUpApprovedSqft: "1450.000",
        superBuiltUpBuiltSqft: "1450.000",
      },
    });
    const flagged = await tx.unit.create({
      data: {
        organizationId: red.id,
        projectId: project.id,
        towerId: tower.id,
        floorId: first.id,
        flatNumber: "A-101",
        facing: "NORTH",
        createdById: owner.id,
        carpetPlannedSqft: "1120.000",
        carpetApprovedSqft: "1120.000",
        carpetBuiltSqft: "1120.000",
        superBuiltUpPlannedSqft: "1680.000",
        superBuiltUpApprovedSqft: "1680.000",
        superBuiltUpBuiltSqft: "1740.000",
      },
    });
    await tx.unitAreaRevision.create({
      data: {
        organizationId: red.id,
        projectId: project.id,
        unitId: flagged.id,
        field: "SUPER_BUILT_UP_BUILT",
        previousSqft: "1680.000",
        newSqft: "1740.000",
        reason: "Site measure came in 60 sqft over the approved super built-up area",
        recordedById: owner.id,
      },
    });
    await tx.unitAreaRevision.create({
      data: {
        organizationId: red.id,
        projectId: project.id,
        unitId: groundFlat.id,
        field: "SUPER_BUILT_UP_BUILT",
        previousSqft: "0.000",
        newSqft: "1450.000",
        reason: "Opening measurement",
        recordedById: owner.id,
      },
    });
  });

  const blue = await ownerDb.organization.findUnique({ where: { slug: "blue-basin" } });
  const blueOwner = await ownerDb.user.findUnique({ where: { email: BLUE_BASIN.ownerEmail } });
  if (!blue || !blueOwner) return;
  const lotus = await ownerDb.project.findFirst({ where: { organizationId: blue.id, code: "LOTUS" } });
  if (lotus) return;
  await ownerDb.$transaction(async (tx) => {
    const project = await tx.project.create({
      data: {
        organizationId: blue.id,
        code: "LOTUS",
        name: "Lotus Court",
        city: "Bengaluru",
        stateCode: "29",
        createdById: blueOwner.id,
      },
    });
    const phase = await tx.projectPhase.create({
      data: { organizationId: blue.id, projectId: project.id, name: "Phase 1", sortOrder: 1 },
    });
    const tower = await tx.tower.create({
      data: { organizationId: blue.id, projectId: project.id, phaseId: phase.id, name: "Tower 1" },
    });
    const floor = await tx.floor.create({
      data: {
        organizationId: blue.id,
        projectId: project.id,
        towerId: tower.id,
        levelNumber: 0,
        label: "Ground",
      },
    });
    await tx.unit.create({
      data: {
        organizationId: blue.id,
        projectId: project.id,
        towerId: tower.id,
        floorId: floor.id,
        flatNumber: "1-G01",
        facing: "WEST",
        createdById: blueOwner.id,
        superBuiltUpPlannedSqft: "1200.000",
        superBuiltUpApprovedSqft: "1200.000",
        superBuiltUpBuiltSqft: "1200.000",
      },
    });
  });
}

export async function seed(): Promise<void> {
  await seedFirm(RED_EARTH, [
    { email: RED_EARTH.ownerEmail, name: RED_EARTH.ownerName, role: "OWNER" },
    { email: "dev.krishnan@red-earth.example", name: "Dev Krishnan", role: "FINANCE" },
    { email: "leela.menon@red-earth.example", name: "Leela Menon", role: "PROJECT_MANAGER" },
    { email: "imran.qureshi@red-earth.example", name: "Imran Qureshi", role: "SITE_ENGINEER" },
    { email: "sana.pillai@red-earth.example", name: "Sana Pillai", role: "SALES" },
    { email: "harish.gowda@red-earth.example", name: "Harish Gowda", role: "AUDITOR" },
    { email: "meena.kulkarni@kaveri-cement.example", name: "Meena Kulkarni", role: "VENDOR", party: "vendor" },
    { email: "nikhil.shetty@buyer.example", name: "Nikhil Shetty", role: "CUSTOMER", party: "customer" },
  ]);
  await seedFirm(BLUE_BASIN, [
    { email: BLUE_BASIN.ownerEmail, name: BLUE_BASIN.ownerName, role: "OWNER" },
  ]);
  await ensureBuildings();
}

const entry = process.argv[1]?.includes("prisma/seed");
if (entry) {
  seed()
    .then(async () => {
      await ownerDb.$disconnect();
    })
    .catch(async (error: unknown) => {
      console.error(error);
      await ownerDb.$disconnect();
      process.exit(1);
    });
}
