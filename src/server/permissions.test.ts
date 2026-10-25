import assert from "node:assert/strict";
import { describe, it } from "node:test";

import { AccessError } from "./errors";
import {
  MEMBERSHIP_ROLES,
  assertCan,
  can,
  visibilityFor,
} from "./permissions";

describe("permission matrix", () => {
  it("names the eight roles from the brief", () => {
    assert.deepEqual(MEMBERSHIP_ROLES, [
      "OWNER",
      "FINANCE",
      "PROJECT_MANAGER",
      "SITE_ENGINEER",
      "SALES",
      "VENDOR",
      "CUSTOMER",
      "AUDITOR",
    ]);
  });

  it("lets every role read and lets only the auditor among the non-writers export", () => {
    for (const role of MEMBERSHIP_ROLES) {
      assert.equal(can(role, "read"), true, role);
    }
    assert.equal(can("AUDITOR", "write"), false);
    assert.equal(can("AUDITOR", "export"), true);
    assert.equal(can("CUSTOMER", "write"), false);
    assert.equal(can("VENDOR", "write"), false);
    assert.equal(can("VENDOR", "invoice.upload"), true);
    assert.equal(can("CUSTOMER", "invoice.upload"), false);
  });

  it("reserves period reopen for the owner and approval for owner and finance", () => {
    assert.equal(can("OWNER", "period.reopen"), true);
    assert.equal(can("FINANCE", "period.reopen"), false);
    assert.equal(can("AUDITOR", "period.reopen"), false);
    assert.equal(can("OWNER", "approve"), true);
    assert.equal(can("FINANCE", "approve"), true);
    assert.equal(can("PROJECT_MANAGER", "approve"), false);
    assert.equal(can("SALES", "write"), true);
    assert.equal(can("SITE_ENGINEER", "write"), true);
  });

  it("scopes project staff to assignments and portals to their own party", () => {
    assert.equal(visibilityFor("OWNER"), "firm");
    assert.equal(visibilityFor("FINANCE"), "firm");
    assert.equal(visibilityFor("AUDITOR"), "firm");
    assert.equal(visibilityFor("PROJECT_MANAGER"), "assigned-projects");
    assert.equal(visibilityFor("SITE_ENGINEER"), "assigned-projects");
    assert.equal(visibilityFor("SALES"), "assigned-projects");
    assert.equal(visibilityFor("VENDOR"), "own-party");
    assert.equal(visibilityFor("CUSTOMER"), "own-party");
  });

  it("refuses an auditor write with a forbidden error", () => {
    assert.throws(() => assertCan("AUDITOR", "write"), (error: unknown) => {
      return error instanceof AccessError && error.code === "FORBIDDEN";
    });
  });
});
