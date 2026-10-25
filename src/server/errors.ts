export type AccessCode =
  | "UNAUTHENTICATED"
  | "FORBIDDEN"
  | "TENANT"
  | "DELETE"
  | "AUDIT"
  | "PERIOD"
  | "APPROVAL"
  | "CHAIN";

export class AccessError extends Error {
  readonly code: AccessCode;

  constructor(message: string, code: AccessCode) {
    super(message);
    this.name = "AccessError";
    this.code = code;
  }
}
