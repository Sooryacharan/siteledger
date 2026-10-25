-- CreateEnum
CREATE TYPE "Locale" AS ENUM ('EN', 'TE', 'HI', 'KN');

-- CreateEnum
CREATE TYPE "MembershipRole" AS ENUM ('OWNER', 'FINANCE', 'PROJECT_MANAGER', 'SITE_ENGINEER', 'SALES', 'VENDOR', 'CUSTOMER', 'AUDITOR');

-- CreateEnum
CREATE TYPE "PartyKind" AS ENUM ('INDIVIDUAL', 'COMPANY', 'LLP', 'PARTNERSHIP', 'HUF', 'TRUST', 'GOVERNMENT');

-- CreateEnum
CREATE TYPE "KycStatus" AS ENUM ('PENDING', 'SUBMITTED', 'VERIFIED', 'REJECTED');

-- CreateEnum
CREATE TYPE "ProjectStatus" AS ENUM ('PLANNING', 'APPROVED', 'IN_PROGRESS', 'HANDED_OVER', 'CLOSED');

-- CreateEnum
CREATE TYPE "CostAreaBasis" AS ENUM ('CARPET', 'BUILT_UP', 'SUPER_BUILT_UP');

-- CreateEnum
CREATE TYPE "UnitStatus" AS ENUM ('AVAILABLE', 'BLOCKED', 'BOOKED', 'AGREEMENT', 'REGISTERED', 'HANDED_OVER', 'CANCELLED', 'LANDOWNER_SHARE');

-- CreateEnum
CREATE TYPE "UnitFacing" AS ENUM ('NORTH', 'SOUTH', 'EAST', 'WEST', 'NORTH_EAST', 'NORTH_WEST', 'SOUTH_EAST', 'SOUTH_WEST');

-- CreateEnum
CREATE TYPE "UnitAreaField" AS ENUM ('CARPET_PLANNED', 'CARPET_APPROVED', 'CARPET_BUILT', 'BUILT_UP_PLANNED', 'BUILT_UP_APPROVED', 'BUILT_UP_BUILT', 'SUPER_BUILT_UP_PLANNED', 'SUPER_BUILT_UP_APPROVED', 'SUPER_BUILT_UP_BUILT');

-- CreateEnum
CREATE TYPE "LeadStatus" AS ENUM ('NEW', 'CONTACTED', 'VISIT_PLANNED', 'VISITED', 'NEGOTIATING', 'BOOKED', 'LOST');

-- CreateEnum
CREATE TYPE "FollowupChannel" AS ENUM ('CALL', 'WHATSAPP', 'EMAIL', 'VISIT');

-- CreateEnum
CREATE TYPE "FollowupOutcome" AS ENUM ('DONE', 'NO_ANSWER', 'RESCHEDULED', 'NOT_INTERESTED');

-- CreateEnum
CREATE TYPE "SiteVisitStatus" AS ENUM ('SCHEDULED', 'COMPLETED', 'NO_SHOW', 'CANCELLED');

-- CreateEnum
CREATE TYPE "BookingStatus" AS ENUM ('TOKEN', 'BOOKED', 'AGREEMENT', 'REGISTERED', 'CANCELLED', 'TRANSFERRED');

-- CreateEnum
CREATE TYPE "DemandMilestone" AS ENUM ('ON_BOOKING', 'ON_AGREEMENT', 'ON_EXCAVATION', 'ON_PLINTH', 'ON_SLAB', 'ON_BRICKWORK', 'ON_FINISHING', 'ON_POSSESSION', 'CUSTOM');

-- CreateEnum
CREATE TYPE "DemandStatus" AS ENUM ('RAISED', 'PART_PAID', 'PAID', 'CANCELLED');

-- CreateEnum
CREATE TYPE "MoneyChannel" AS ENUM ('NEFT', 'RTGS', 'IMPS', 'UPI', 'CHEQUE', 'CASH');

-- CreateEnum
CREATE TYPE "ReceiptStatus" AS ENUM ('DRAFT', 'POSTED', 'VOID');

-- CreateEnum
CREATE TYPE "AgreementKind" AS ENUM ('ALLOTMENT', 'AGREEMENT_FOR_SALE', 'SALE_DEED', 'CONSTRUCTION_AGREEMENT');

-- CreateEnum
CREATE TYPE "AgreementStatus" AS ENUM ('DRAFT', 'SIGNED', 'REGISTERED', 'CANCELLED');

-- CreateEnum
CREATE TYPE "TransferChargePayer" AS ENUM ('FROM_BUYER', 'TO_BUYER', 'DEVELOPER');

-- CreateEnum
CREATE TYPE "ShareBasis" AS ENUM ('PROFIT', 'REVENUE', 'SALEABLE_AREA');

-- CreateEnum
CREATE TYPE "ShareEntryType" AS ENUM ('CONTRIBUTION', 'DRAWING', 'HURDLE', 'PROFIT', 'LOSS', 'FIXED', 'ADJUSTMENT');

-- CreateEnum
CREATE TYPE "CapitalInstrument" AS ENUM ('EQUITY', 'LAND', 'OTHER');

-- CreateEnum
CREATE TYPE "AllocationReason" AS ENUM ('LAND_SHARE', 'INVESTOR', 'MARKETING');

-- CreateEnum
CREATE TYPE "IndentStatus" AS ENUM ('DRAFT', 'SUBMITTED', 'QUOTED', 'ORDERED', 'CLOSED', 'CANCELLED');

-- CreateEnum
CREATE TYPE "QuoteStatus" AS ENUM ('DRAFT', 'RECEIVED', 'SELECTED', 'REJECTED');

-- CreateEnum
CREATE TYPE "PurchaseOrderStatus" AS ENUM ('DRAFT', 'ISSUED', 'PART_RECEIVED', 'RECEIVED', 'CLOSED', 'CANCELLED');

-- CreateEnum
CREATE TYPE "GrnStatus" AS ENUM ('DRAFT', 'POSTED', 'VOID');

-- CreateEnum
CREATE TYPE "InvoiceStatus" AS ENUM ('DRAFT', 'SUBMITTED', 'MATCHED', 'APPROVED', 'PART_PAID', 'PAID', 'REJECTED', 'VOID');

-- CreateEnum
CREATE TYPE "InvoiceSource" AS ENUM ('INTERNAL', 'VENDOR_PORTAL');

-- CreateEnum
CREATE TYPE "MatchStatus" AS ENUM ('MATCHED', 'QTY_VARIANCE', 'RATE_VARIANCE', 'MISSING_GRN', 'MISSING_PO');

-- CreateEnum
CREATE TYPE "SupplyType" AS ENUM ('INTRA_STATE', 'INTER_STATE');

-- CreateEnum
CREATE TYPE "StockMovement" AS ENUM ('RECEIPT', 'ISSUE', 'TRANSFER_IN', 'TRANSFER_OUT', 'ADJUSTMENT', 'RETURN');

-- CreateEnum
CREATE TYPE "ValuationMethod" AS ENUM ('WEIGHTED_AVERAGE');

-- CreateEnum
CREATE TYPE "WorkOrderStatus" AS ENUM ('DRAFT', 'ISSUED', 'IN_PROGRESS', 'CLOSED', 'CANCELLED');

-- CreateEnum
CREATE TYPE "MeasurementStatus" AS ENUM ('DRAFT', 'CHECKED', 'BILLED');

-- CreateEnum
CREATE TYPE "RaBillStatus" AS ENUM ('DRAFT', 'SUBMITTED', 'APPROVED', 'PART_PAID', 'PAID', 'REJECTED', 'VOID');

-- CreateEnum
CREATE TYPE "AttendanceStatus" AS ENUM ('PRESENT', 'ABSENT', 'HALF_DAY');

-- CreateEnum
CREATE TYPE "RetentionAction" AS ENUM ('HOLD', 'RELEASE');

-- CreateEnum
CREATE TYPE "AdvanceStatus" AS ENUM ('OPEN', 'CLOSED');

-- CreateEnum
CREATE TYPE "AccountType" AS ENUM ('ASSET', 'LIABILITY', 'EQUITY', 'INCOME', 'EXPENSE');

-- CreateEnum
CREATE TYPE "NormalBalance" AS ENUM ('DEBIT', 'CREDIT');

-- CreateEnum
CREATE TYPE "FiscalYearStatus" AS ENUM ('OPEN', 'CLOSED');

-- CreateEnum
CREATE TYPE "PeriodStatus" AS ENUM ('OPEN', 'SOFT_CLOSED', 'LOCKED');

-- CreateEnum
CREATE TYPE "PeriodLockAction" AS ENUM ('SOFT_CLOSE', 'LOCK', 'REOPEN_REQUEST', 'REOPEN');

-- CreateEnum
CREATE TYPE "JournalStatus" AS ENUM ('DRAFT', 'POSTED', 'REVERSED');

-- CreateEnum
CREATE TYPE "JournalSource" AS ENUM ('MANUAL', 'RECEIPT', 'PAYMENT', 'VENDOR_INVOICE', 'RA_BILL', 'CUSTOMER_INTEREST', 'LOAN_INTEREST', 'LOAN_DRAWDOWN', 'LOAN_EMI', 'LOAN_PREPAYMENT', 'CAPITAL', 'RETENTION', 'CONTRACTOR_ADVANCE', 'ADVANCE_RECOVERY', 'CUSTOMER_REFUND', 'TALLY_IMPORT', 'REVERSAL');

-- CreateEnum
CREATE TYPE "BankMatchStatus" AS ENUM ('UNMATCHED', 'MATCHED', 'IGNORED');

-- CreateEnum
CREATE TYPE "BudgetStatus" AS ENUM ('DRAFT', 'ACTIVE', 'SUPERSEDED');

-- CreateEnum
CREATE TYPE "LoanKind" AS ENUM ('BANK', 'PARTNER', 'NBFC');

-- CreateEnum
CREATE TYPE "LoanStatus" AS ENUM ('DRAFT', 'ACTIVE', 'CLOSED');

-- CreateEnum
CREATE TYPE "LoanRepaymentStyle" AS ENUM ('EMI', 'INTEREST_ONLY', 'ON_DEMAND');

-- CreateEnum
CREATE TYPE "EmiStatus" AS ENUM ('DUE', 'PART_PAID', 'PAID', 'WAIVED', 'SUPERSEDED');

-- CreateEnum
CREATE TYPE "LoanTxnType" AS ENUM ('DRAWDOWN', 'EMI_PAYMENT', 'PREPAYMENT', 'INTEREST_PAYMENT', 'FEE', 'PENALTY');

-- CreateEnum
CREATE TYPE "PaymentPurpose" AS ENUM ('VENDOR_INVOICE', 'RA_BILL', 'CONTRACTOR_ADVANCE', 'LOAN_REPAYMENT', 'CUSTOMER_REFUND', 'RETENTION_RELEASE', 'STATUTORY', 'OTHER');

-- CreateEnum
CREATE TYPE "PaymentStatus" AS ENUM ('DRAFT', 'SUBMITTED', 'APPROVED', 'PAID', 'VOID');

-- CreateEnum
CREATE TYPE "ApprovalEntity" AS ENUM ('PAYMENT', 'VENDOR_INVOICE', 'RA_BILL', 'JOURNAL', 'BOOKING_CANCELLATION', 'BOOKING_TRANSFER', 'STOCK_ADJUSTMENT', 'PERIOD_REOPEN', 'WORK_ORDER', 'PURCHASE_ORDER', 'CUSTOMER_REFUND');

-- CreateEnum
CREATE TYPE "ApprovalStatus" AS ENUM ('PENDING', 'APPROVED', 'REJECTED', 'CANCELLED');

-- CreateEnum
CREATE TYPE "ApprovalDecision" AS ENUM ('APPROVED', 'REJECTED', 'RETURNED');

-- CreateEnum
CREATE TYPE "ExceptionCode" AS ENUM ('UNMATCHED_BANK_LINE', 'PAYMENT_WITHOUT_INVOICE', 'INVOICE_WITHOUT_GRN', 'AREA_VARIANCE', 'MATERIAL_VARIANCE', 'WASTAGE_OVER_NORM', 'ROUND_FIGURE_PAYMENT', 'WEEKEND_PAYMENT', 'DUPLICATE_INVOICE', 'DUPLICATE_VENDOR', 'APPROVAL_OVERDUE', 'MISSING_PAYMENT_DOCUMENT', 'MISSING_APPROVAL', 'PERIOD_LOCK_REJECTED', 'SYNC_REJECTED', 'NEGATIVE_STOCK', 'RELATED_PARTY_PAYMENT', 'BUDGET_OVERRUN', 'GST_SPLIT_MISMATCH');

-- CreateEnum
CREATE TYPE "ExceptionSeverity" AS ENUM ('INFO', 'WARNING', 'CRITICAL');

-- CreateEnum
CREATE TYPE "ExceptionStatus" AS ENUM ('OPEN', 'ACKNOWLEDGED', 'RESOLVED');

-- CreateEnum
CREATE TYPE "NotificationChannel" AS ENUM ('WHATSAPP', 'EMAIL', 'IN_APP');

-- CreateEnum
CREATE TYPE "NotificationStatus" AS ENUM ('QUEUED', 'SENT', 'FAILED');

-- CreateEnum
CREATE TYPE "RecordRef" AS ENUM ('PROJECT', 'PHASE', 'TOWER', 'FLOOR', 'UNIT', 'PARTY', 'LEAD', 'BOOKING', 'AGREEMENT', 'BOOKING_CANCELLATION', 'BOOKING_TRANSFER', 'DEMAND_NOTE', 'RECEIPT', 'INTEREST_ACCRUAL', 'CAPITAL_CONTRIBUTION', 'PROFIT_SHARING_AGREEMENT', 'SHARE_COMPUTATION', 'INDENT', 'VENDOR_QUOTE', 'PURCHASE_ORDER', 'GOODS_RECEIPT', 'VENDOR_INVOICE', 'PAYMENT', 'JOURNAL_ENTRY', 'RA_BILL', 'WORK_ORDER', 'MEASUREMENT', 'MATERIAL_ISSUE', 'LABOUR_ATTENDANCE', 'LOAN', 'EMI_SCHEDULE', 'BANK_STATEMENT', 'IMPORT_BATCH', 'PROGRESS_UPDATE', 'CUSTOMER_STATEMENT', 'CONTRACTOR_ADVANCE', 'BUDGET', 'USER', 'MEMBERSHIP', 'ACCOUNTING_PERIOD', 'APPROVAL_REQUEST', 'GL_ACCOUNT', 'BANK_ACCOUNT', 'ORGANIZATION', 'FISCAL_YEAR', 'APPROVAL_POLICY', 'APPROVAL_ACTION', 'PERIOD_LOCK_EVENT', 'PROJECT_ASSIGNMENT', 'DEVICE', 'JOURNAL_LINE');

-- CreateEnum
CREATE TYPE "OcrStatus" AS ENUM ('PENDING', 'RUNNING', 'DONE', 'FAILED', 'SKIPPED');

-- CreateEnum
CREATE TYPE "ImportKind" AS ENUM ('EXCEL_UNITS', 'EXCEL_LEADS', 'EXCEL_VENDORS', 'EXCEL_ATTENDANCE', 'BANK_CSV', 'BANK_PDF', 'TALLY_XML', 'TALLY_XLSX');

-- CreateEnum
CREATE TYPE "ImportStatus" AS ENUM ('PENDING', 'PROCESSING', 'COMPLETED', 'FAILED');

-- CreateEnum
CREATE TYPE "OfflineEntity" AS ENUM ('LABOUR_ATTENDANCE', 'MATERIAL_ISSUE', 'MEASUREMENT', 'GOODS_RECEIPT', 'PROGRESS_UPDATE', 'RECEIPT');

-- CreateEnum
CREATE TYPE "SyncStatus" AS ENUM ('PENDING', 'APPLIED', 'REJECTED');

-- CreateEnum
CREATE TYPE "ChainName" AS ENUM ('JOURNAL', 'STOCK', 'SHARE', 'AUDIT');

-- CreateEnum
CREATE TYPE "AuditAction" AS ENUM ('CREATE', 'UPDATE', 'SOFT_DELETE', 'POST', 'REVERSE', 'APPROVE', 'REJECT', 'LOGIN', 'EXPORT', 'LOCK', 'REOPEN');

-- CreateEnum
CREATE TYPE "DevicePlatform" AS ENUM ('ANDROID', 'IOS', 'WEB');

-- CreateEnum
CREATE TYPE "ComputationStatus" AS ENUM ('POSTED', 'SUPERSEDED');

-- CreateTable
CREATE TABLE "organizations" (
    "id" UUID NOT NULL,
    "slug" TEXT NOT NULL,
    "legal_name" TEXT NOT NULL,
    "display_name" TEXT NOT NULL,
    "pan" TEXT,
    "pan_shape_valid" BOOLEAN,
    "gstin" TEXT,
    "gstin_checksum_valid" BOOLEAN,
    "gstin_validated_at" TIMESTAMP(3),
    "state_code" TEXT NOT NULL,
    "city" TEXT,
    "timezone" TEXT NOT NULL DEFAULT 'Asia/Kolkata',
    "locale" "Locale" NOT NULL DEFAULT 'EN',
    "created_at" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "updated_at" TIMESTAMP(3) NOT NULL,
    "deleted_at" TIMESTAMP(3),

    CONSTRAINT "organizations_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "users" (
    "id" UUID NOT NULL,
    "name" TEXT,
    "email" TEXT NOT NULL,
    "email_verified" TIMESTAMP(3),
    "image" TEXT,
    "phone_e164" TEXT,
    "locale" "Locale" NOT NULL DEFAULT 'EN',
    "created_at" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "updated_at" TIMESTAMP(3) NOT NULL,
    "deleted_at" TIMESTAMP(3),

    CONSTRAINT "users_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "auth_accounts" (
    "id" UUID NOT NULL,
    "user_id" UUID NOT NULL,
    "type" TEXT NOT NULL,
    "provider" TEXT NOT NULL,
    "provider_account_id" TEXT NOT NULL,
    "refresh_token" TEXT,
    "access_token" TEXT,
    "expires_at" INTEGER,
    "token_type" TEXT,
    "scope" TEXT,
    "id_token" TEXT,
    "session_state" TEXT,

    CONSTRAINT "auth_accounts_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "auth_sessions" (
    "id" UUID NOT NULL,
    "session_token" TEXT NOT NULL,
    "user_id" UUID NOT NULL,
    "expires" TIMESTAMP(3) NOT NULL,

    CONSTRAINT "auth_sessions_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "auth_verification_tokens" (
    "id" UUID NOT NULL,
    "identifier" TEXT NOT NULL,
    "token" TEXT NOT NULL,
    "expires" TIMESTAMP(3) NOT NULL,

    CONSTRAINT "auth_verification_tokens_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "memberships" (
    "id" UUID NOT NULL,
    "organization_id" UUID NOT NULL,
    "user_id" UUID NOT NULL,
    "role" "MembershipRole" NOT NULL,
    "party_id" UUID,
    "is_active" BOOLEAN NOT NULL DEFAULT true,
    "created_at" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "updated_at" TIMESTAMP(3) NOT NULL,
    "deleted_at" TIMESTAMP(3),
    "created_by_id" UUID,
    "updated_by_id" UUID,

    CONSTRAINT "memberships_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "project_assignments" (
    "id" UUID NOT NULL,
    "organization_id" UUID NOT NULL,
    "user_id" UUID NOT NULL,
    "project_id" UUID NOT NULL,
    "created_at" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "deleted_at" TIMESTAMP(3),
    "created_by_id" UUID,

    CONSTRAINT "project_assignments_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "devices" (
    "id" UUID NOT NULL,
    "organization_id" UUID NOT NULL,
    "user_id" UUID NOT NULL,
    "label" TEXT NOT NULL,
    "platform" "DevicePlatform" NOT NULL,
    "last_seen_at" TIMESTAMP(3),
    "revoked_at" TIMESTAMP(3),
    "created_at" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,

    CONSTRAINT "devices_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "audit_events" (
    "id" UUID NOT NULL,
    "organization_id" UUID NOT NULL,
    "actor_id" UUID,
    "action" "AuditAction" NOT NULL,
    "entity_type" "RecordRef" NOT NULL,
    "entity_id" UUID,
    "occurred_at" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "before" JSONB,
    "after" JSONB,
    "request_id" TEXT,
    "ip_address" TEXT,
    "user_agent" TEXT,
    "device_id" UUID,
    "sequence" INTEGER NOT NULL,
    "prev_hash" TEXT NOT NULL,
    "event_hash" TEXT NOT NULL,
    "created_at" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,

    CONSTRAINT "audit_events_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "chain_heads" (
    "id" UUID NOT NULL,
    "organization_id" UUID NOT NULL,
    "chain" "ChainName" NOT NULL,
    "last_hash" TEXT NOT NULL,
    "last_sequence" INTEGER NOT NULL DEFAULT 0,
    "updated_at" TIMESTAMP(3) NOT NULL,

    CONSTRAINT "chain_heads_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "approval_policies" (
    "id" UUID NOT NULL,
    "organization_id" UUID NOT NULL,
    "entity_type" "ApprovalEntity" NOT NULL,
    "min_amount_paise" BIGINT NOT NULL DEFAULT 0,
    "max_amount_paise" BIGINT,
    "step_order" INTEGER NOT NULL,
    "approver_role" "MembershipRole",
    "auto_approve" BOOLEAN NOT NULL DEFAULT false,
    "plain_language" TEXT NOT NULL,
    "is_active" BOOLEAN NOT NULL DEFAULT true,
    "created_at" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "updated_at" TIMESTAMP(3) NOT NULL,
    "deleted_at" TIMESTAMP(3),
    "created_by_id" UUID,
    "updated_by_id" UUID,

    CONSTRAINT "approval_policies_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "approval_requests" (
    "id" UUID NOT NULL,
    "organization_id" UUID NOT NULL,
    "entity_type" "ApprovalEntity" NOT NULL,
    "entity_id" UUID NOT NULL,
    "amount_paise" BIGINT,
    "status" "ApprovalStatus" NOT NULL DEFAULT 'PENDING',
    "current_step" INTEGER NOT NULL DEFAULT 1,
    "requested_by_id" UUID NOT NULL,
    "created_at" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "completed_at" TIMESTAMP(3),

    CONSTRAINT "approval_requests_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "approval_actions" (
    "id" UUID NOT NULL,
    "organization_id" UUID NOT NULL,
    "request_id" UUID NOT NULL,
    "step_order" INTEGER NOT NULL,
    "actor_id" UUID,
    "decision" "ApprovalDecision" NOT NULL,
    "comment" TEXT,
    "acted_at" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,

    CONSTRAINT "approval_actions_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "fiscal_years" (
    "id" UUID NOT NULL,
    "organization_id" UUID NOT NULL,
    "name" TEXT NOT NULL,
    "starts_on" DATE NOT NULL,
    "ends_on" DATE NOT NULL,
    "status" "FiscalYearStatus" NOT NULL DEFAULT 'OPEN',
    "created_at" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "updated_at" TIMESTAMP(3) NOT NULL,

    CONSTRAINT "fiscal_years_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "accounting_periods" (
    "id" UUID NOT NULL,
    "organization_id" UUID NOT NULL,
    "fiscal_year_id" UUID NOT NULL,
    "name" TEXT NOT NULL,
    "starts_on" DATE NOT NULL,
    "ends_on" DATE NOT NULL,
    "status" "PeriodStatus" NOT NULL DEFAULT 'OPEN',
    "locked_at" TIMESTAMP(3),
    "locked_by_id" UUID,
    "created_at" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "updated_at" TIMESTAMP(3) NOT NULL,

    CONSTRAINT "accounting_periods_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "period_lock_events" (
    "id" UUID NOT NULL,
    "organization_id" UUID NOT NULL,
    "period_id" UUID NOT NULL,
    "action" "PeriodLockAction" NOT NULL,
    "reason" TEXT NOT NULL,
    "actor_id" UUID NOT NULL,
    "approval_request_id" UUID,
    "occurred_at" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,

    CONSTRAINT "period_lock_events_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "gst_rates" (
    "id" UUID NOT NULL,
    "name" TEXT NOT NULL,
    "cgst_percent" DECIMAL(8,4) NOT NULL,
    "sgst_percent" DECIMAL(8,4) NOT NULL,
    "igst_percent" DECIMAL(8,4) NOT NULL,
    "cess_percent" DECIMAL(8,4) NOT NULL DEFAULT 0,
    "effective_from" DATE NOT NULL,
    "effective_to" DATE,
    "is_active" BOOLEAN NOT NULL DEFAULT true,

    CONSTRAINT "gst_rates_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "tds_sections" (
    "id" UUID NOT NULL,
    "code" TEXT NOT NULL,
    "description" TEXT NOT NULL,
    "rate_percent" DECIMAL(8,4) NOT NULL,
    "threshold_paise" BIGINT,
    "is_active" BOOLEAN NOT NULL DEFAULT true,

    CONSTRAINT "tds_sections_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "document_sequences" (
    "id" UUID NOT NULL,
    "organization_id" UUID NOT NULL,
    "fiscal_year_id" UUID NOT NULL,
    "doc_type" TEXT NOT NULL,
    "prefix" TEXT NOT NULL,
    "next_number" INTEGER NOT NULL DEFAULT 1,

    CONSTRAINT "document_sequences_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "parties" (
    "id" UUID NOT NULL,
    "organization_id" UUID NOT NULL,
    "kind" "PartyKind" NOT NULL,
    "legal_name" TEXT NOT NULL,
    "display_name" TEXT NOT NULL,
    "pan" TEXT,
    "pan_normalized" TEXT,
    "pan_shape_valid" BOOLEAN,
    "gstin" TEXT,
    "gstin_normalized" TEXT,
    "gstin_checksum_valid" BOOLEAN,
    "gstin_validated_at" TIMESTAMP(3),
    "is_customer" BOOLEAN NOT NULL DEFAULT false,
    "is_vendor" BOOLEAN NOT NULL DEFAULT false,
    "is_contractor" BOOLEAN NOT NULL DEFAULT false,
    "is_partner" BOOLEAN NOT NULL DEFAULT false,
    "is_lender" BOOLEAN NOT NULL DEFAULT false,
    "is_related_party" BOOLEAN NOT NULL DEFAULT false,
    "related_to_party_id" UUID,
    "related_party_note" TEXT,
    "row_version" INTEGER NOT NULL DEFAULT 1,
    "created_at" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "updated_at" TIMESTAMP(3) NOT NULL,
    "deleted_at" TIMESTAMP(3),
    "created_by_id" UUID,
    "updated_by_id" UUID,

    CONSTRAINT "parties_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "party_addresses" (
    "id" UUID NOT NULL,
    "organization_id" UUID NOT NULL,
    "party_id" UUID NOT NULL,
    "line_1" TEXT NOT NULL,
    "line_2" TEXT,
    "city" TEXT NOT NULL,
    "state_code" TEXT NOT NULL,
    "pincode" TEXT NOT NULL,
    "is_primary" BOOLEAN NOT NULL DEFAULT false,
    "created_at" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "updated_at" TIMESTAMP(3) NOT NULL,
    "deleted_at" TIMESTAMP(3),

    CONSTRAINT "party_addresses_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "party_bank_accounts" (
    "id" UUID NOT NULL,
    "organization_id" UUID NOT NULL,
    "party_id" UUID NOT NULL,
    "bank_name" TEXT NOT NULL,
    "account_holder" TEXT NOT NULL,
    "account_number" TEXT NOT NULL,
    "ifsc" TEXT NOT NULL,
    "fingerprint" TEXT NOT NULL,
    "is_primary" BOOLEAN NOT NULL DEFAULT false,
    "created_at" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "updated_at" TIMESTAMP(3) NOT NULL,
    "deleted_at" TIMESTAMP(3),

    CONSTRAINT "party_bank_accounts_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "party_contacts" (
    "id" UUID NOT NULL,
    "organization_id" UUID NOT NULL,
    "party_id" UUID NOT NULL,
    "name" TEXT,
    "phone_e164" TEXT,
    "email" TEXT,
    "is_primary" BOOLEAN NOT NULL DEFAULT false,
    "created_at" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "updated_at" TIMESTAMP(3) NOT NULL,
    "deleted_at" TIMESTAMP(3),

    CONSTRAINT "party_contacts_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "vendor_profiles" (
    "id" UUID NOT NULL,
    "organization_id" UUID NOT NULL,
    "party_id" UUID NOT NULL,
    "kyc_status" "KycStatus" NOT NULL DEFAULT 'PENDING',
    "udyam_number" TEXT,
    "tds_section_id" UUID,
    "tds_rate_override_percent" DECIMAL(8,4),
    "notes" TEXT,
    "created_at" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "updated_at" TIMESTAMP(3) NOT NULL,
    "deleted_at" TIMESTAMP(3),

    CONSTRAINT "vendor_profiles_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "contractor_profiles" (
    "id" UUID NOT NULL,
    "organization_id" UUID NOT NULL,
    "party_id" UUID NOT NULL,
    "license_number" TEXT,
    "pf_establishment_code" TEXT,
    "esi_code" TEXT,
    "default_retention_percent" DECIMAL(8,4) NOT NULL DEFAULT 5,
    "created_at" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "updated_at" TIMESTAMP(3) NOT NULL,
    "deleted_at" TIMESTAMP(3),

    CONSTRAINT "contractor_profiles_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "projects" (
    "id" UUID NOT NULL,
    "organization_id" UUID NOT NULL,
    "code" TEXT NOT NULL,
    "name" TEXT NOT NULL,
    "status" "ProjectStatus" NOT NULL DEFAULT 'PLANNING',
    "address_line" TEXT,
    "city" TEXT,
    "state_code" TEXT NOT NULL,
    "pincode" TEXT,
    "rera_registration_number" TEXT,
    "rera_state_code" TEXT,
    "rera_valid_from" DATE,
    "rera_valid_until" DATE,
    "gstin" TEXT,
    "gstin_checksum_valid" BOOLEAN,
    "cost_area_basis" "CostAreaBasis" NOT NULL DEFAULT 'SUPER_BUILT_UP',
    "area_variance_alert_percent" DECIMAL(8,4) NOT NULL DEFAULT 2,
    "wastage_alert_percent" DECIMAL(8,4) NOT NULL DEFAULT 2,
    "starts_on" DATE,
    "planned_ends_on" DATE,
    "row_version" INTEGER NOT NULL DEFAULT 1,
    "created_at" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "updated_at" TIMESTAMP(3) NOT NULL,
    "deleted_at" TIMESTAMP(3),
    "created_by_id" UUID,
    "updated_by_id" UUID,

    CONSTRAINT "projects_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "project_phases" (
    "id" UUID NOT NULL,
    "organization_id" UUID NOT NULL,
    "project_id" UUID NOT NULL,
    "name" TEXT NOT NULL,
    "sort_order" INTEGER NOT NULL,
    "starts_on" DATE,
    "ends_on" DATE,
    "created_at" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "updated_at" TIMESTAMP(3) NOT NULL,
    "deleted_at" TIMESTAMP(3),

    CONSTRAINT "project_phases_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "towers" (
    "id" UUID NOT NULL,
    "organization_id" UUID NOT NULL,
    "project_id" UUID NOT NULL,
    "phase_id" UUID,
    "name" TEXT NOT NULL,
    "created_at" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "updated_at" TIMESTAMP(3) NOT NULL,
    "deleted_at" TIMESTAMP(3),

    CONSTRAINT "towers_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "floors" (
    "id" UUID NOT NULL,
    "organization_id" UUID NOT NULL,
    "project_id" UUID NOT NULL,
    "tower_id" UUID NOT NULL,
    "level_number" INTEGER NOT NULL,
    "label" TEXT NOT NULL,
    "created_at" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "updated_at" TIMESTAMP(3) NOT NULL,
    "deleted_at" TIMESTAMP(3),

    CONSTRAINT "floors_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "units" (
    "id" UUID NOT NULL,
    "organization_id" UUID NOT NULL,
    "project_id" UUID NOT NULL,
    "tower_id" UUID,
    "floor_id" UUID,
    "flat_number" TEXT NOT NULL,
    "typology" TEXT,
    "facing" "UnitFacing",
    "status" "UnitStatus" NOT NULL DEFAULT 'AVAILABLE',
    "carpet_planned_sqft" DECIMAL(14,3) NOT NULL DEFAULT 0,
    "carpet_approved_sqft" DECIMAL(14,3) NOT NULL DEFAULT 0,
    "carpet_built_sqft" DECIMAL(14,3) NOT NULL DEFAULT 0,
    "built_up_planned_sqft" DECIMAL(14,3) NOT NULL DEFAULT 0,
    "built_up_approved_sqft" DECIMAL(14,3) NOT NULL DEFAULT 0,
    "built_up_built_sqft" DECIMAL(14,3) NOT NULL DEFAULT 0,
    "super_built_up_planned_sqft" DECIMAL(14,3) NOT NULL DEFAULT 0,
    "super_built_up_approved_sqft" DECIMAL(14,3) NOT NULL DEFAULT 0,
    "super_built_up_built_sqft" DECIMAL(14,3) NOT NULL DEFAULT 0,
    "row_version" INTEGER NOT NULL DEFAULT 1,
    "created_at" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "updated_at" TIMESTAMP(3) NOT NULL,
    "deleted_at" TIMESTAMP(3),
    "created_by_id" UUID,
    "updated_by_id" UUID,

    CONSTRAINT "units_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "unit_area_revisions" (
    "id" UUID NOT NULL,
    "organization_id" UUID NOT NULL,
    "project_id" UUID NOT NULL,
    "unit_id" UUID NOT NULL,
    "field" "UnitAreaField" NOT NULL,
    "previous_sqft" DECIMAL(14,3) NOT NULL,
    "new_sqft" DECIMAL(14,3) NOT NULL,
    "reason" TEXT NOT NULL,
    "recorded_at" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "recorded_by_id" UUID NOT NULL,

    CONSTRAINT "unit_area_revisions_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "cost_centres" (
    "id" UUID NOT NULL,
    "organization_id" UUID NOT NULL,
    "project_id" UUID NOT NULL,
    "parent_id" UUID,
    "code" TEXT NOT NULL,
    "name" TEXT NOT NULL,
    "is_active" BOOLEAN NOT NULL DEFAULT true,
    "created_at" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "updated_at" TIMESTAMP(3) NOT NULL,
    "deleted_at" TIMESTAMP(3),

    CONSTRAINT "cost_centres_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "boq_items" (
    "id" UUID NOT NULL,
    "organization_id" UUID NOT NULL,
    "project_id" UUID NOT NULL,
    "cost_centre_id" UUID,
    "material_id" UUID,
    "code" TEXT NOT NULL,
    "description" TEXT NOT NULL,
    "uom" TEXT NOT NULL,
    "norm_qty" DECIMAL(18,4),
    "norm_qty_per_sqft" DECIMAL(18,6),
    "wastage_allowance_percent" DECIMAL(8,4) NOT NULL DEFAULT 0,
    "estimated_rate_rupees" DECIMAL(18,4),
    "created_at" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "updated_at" TIMESTAMP(3) NOT NULL,
    "deleted_at" TIMESTAMP(3),

    CONSTRAINT "boq_items_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "leads" (
    "id" UUID NOT NULL,
    "organization_id" UUID NOT NULL,
    "project_id" UUID,
    "assigned_to_id" UUID,
    "name" TEXT NOT NULL,
    "phone_e164" TEXT,
    "email" TEXT,
    "source" TEXT,
    "status" "LeadStatus" NOT NULL DEFAULT 'NEW',
    "budget_min_paise" BIGINT,
    "budget_max_paise" BIGINT,
    "preferred_typology" TEXT,
    "lost_reason" TEXT,
    "notes" TEXT,
    "created_at" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "updated_at" TIMESTAMP(3) NOT NULL,
    "deleted_at" TIMESTAMP(3),
    "created_by_id" UUID,
    "updated_by_id" UUID,

    CONSTRAINT "leads_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "lead_followups" (
    "id" UUID NOT NULL,
    "organization_id" UUID NOT NULL,
    "lead_id" UUID NOT NULL,
    "assigned_to_id" UUID,
    "due_on" TIMESTAMP(3) NOT NULL,
    "channel" "FollowupChannel" NOT NULL,
    "notes" TEXT,
    "completed_at" TIMESTAMP(3),
    "outcome" "FollowupOutcome",
    "created_at" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "updated_at" TIMESTAMP(3) NOT NULL,
    "deleted_at" TIMESTAMP(3),

    CONSTRAINT "lead_followups_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "site_visits" (
    "id" UUID NOT NULL,
    "organization_id" UUID NOT NULL,
    "lead_id" UUID NOT NULL,
    "project_id" UUID NOT NULL,
    "unit_id" UUID,
    "conducted_by_id" UUID NOT NULL,
    "status" "SiteVisitStatus" NOT NULL DEFAULT 'SCHEDULED',
    "scheduled_start" TIMESTAMP(3) NOT NULL,
    "visited_at" TIMESTAMP(3),
    "notes" TEXT,
    "created_at" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "updated_at" TIMESTAMP(3) NOT NULL,
    "deleted_at" TIMESTAMP(3),

    CONSTRAINT "site_visits_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "lead_activities" (
    "id" UUID NOT NULL,
    "organization_id" UUID NOT NULL,
    "lead_id" UUID NOT NULL,
    "actor_id" UUID NOT NULL,
    "channel" "FollowupChannel" NOT NULL,
    "body" TEXT NOT NULL,
    "happened_at" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,

    CONSTRAINT "lead_activities_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "bookings" (
    "id" UUID NOT NULL,
    "organization_id" UUID NOT NULL,
    "project_id" UUID NOT NULL,
    "unit_id" UUID NOT NULL,
    "lead_id" UUID,
    "sales_owner_id" UUID NOT NULL,
    "booking_number" TEXT NOT NULL,
    "booked_on" DATE NOT NULL,
    "status" "BookingStatus" NOT NULL DEFAULT 'TOKEN',
    "base_value_paise" BIGINT NOT NULL,
    "gst_rate_id" UUID,
    "supply_type" "SupplyType" NOT NULL,
    "cgst_paise" BIGINT NOT NULL DEFAULT 0,
    "sgst_paise" BIGINT NOT NULL DEFAULT 0,
    "igst_paise" BIGINT NOT NULL DEFAULT 0,
    "cess_paise" BIGINT NOT NULL DEFAULT 0,
    "charges_paise" BIGINT NOT NULL DEFAULT 0,
    "charges_gst_paise" BIGINT NOT NULL DEFAULT 0,
    "total_payable_paise" BIGINT NOT NULL,
    "notes" TEXT,
    "row_version" INTEGER NOT NULL DEFAULT 1,
    "created_at" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "updated_at" TIMESTAMP(3) NOT NULL,
    "deleted_at" TIMESTAMP(3),
    "created_by_id" UUID,
    "updated_by_id" UUID,

    CONSTRAINT "bookings_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "booking_customers" (
    "id" UUID NOT NULL,
    "organization_id" UUID NOT NULL,
    "booking_id" UUID NOT NULL,
    "party_id" UUID NOT NULL,
    "is_primary" BOOLEAN NOT NULL DEFAULT false,
    "share_percent" DECIMAL(8,4) NOT NULL DEFAULT 100,
    "created_at" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "deleted_at" TIMESTAMP(3),

    CONSTRAINT "booking_customers_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "booking_charges" (
    "id" UUID NOT NULL,
    "organization_id" UUID NOT NULL,
    "booking_id" UUID NOT NULL,
    "description" TEXT NOT NULL,
    "amount_paise" BIGINT NOT NULL,
    "cgst_paise" BIGINT NOT NULL DEFAULT 0,
    "sgst_paise" BIGINT NOT NULL DEFAULT 0,
    "igst_paise" BIGINT NOT NULL DEFAULT 0,
    "cess_paise" BIGINT NOT NULL DEFAULT 0,
    "created_at" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "updated_at" TIMESTAMP(3) NOT NULL,
    "deleted_at" TIMESTAMP(3),

    CONSTRAINT "booking_charges_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "agreements" (
    "id" UUID NOT NULL,
    "organization_id" UUID NOT NULL,
    "project_id" UUID NOT NULL,
    "booking_id" UUID NOT NULL,
    "agreement_number" TEXT NOT NULL,
    "kind" "AgreementKind" NOT NULL,
    "status" "AgreementStatus" NOT NULL DEFAULT 'DRAFT',
    "signed_on" DATE,
    "registered_on" DATE,
    "registration_number" TEXT,
    "sub_registrar" TEXT,
    "stamp_duty_paise" BIGINT NOT NULL DEFAULT 0,
    "registration_fee_paise" BIGINT NOT NULL DEFAULT 0,
    "created_at" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "updated_at" TIMESTAMP(3) NOT NULL,
    "deleted_at" TIMESTAMP(3),
    "created_by_id" UUID,
    "updated_by_id" UUID,

    CONSTRAINT "agreements_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "booking_cancellations" (
    "id" UUID NOT NULL,
    "organization_id" UUID NOT NULL,
    "project_id" UUID NOT NULL,
    "booking_id" UUID NOT NULL,
    "cancelled_on" DATE NOT NULL,
    "reason" TEXT NOT NULL,
    "deduction_paise" BIGINT NOT NULL DEFAULT 0,
    "refund_paise" BIGINT NOT NULL DEFAULT 0,
    "interest_reversed_paise" BIGINT NOT NULL DEFAULT 0,
    "approval_request_id" UUID,
    "journal_entry_id" UUID,
    "created_at" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "created_by_id" UUID,

    CONSTRAINT "booking_cancellations_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "booking_transfers" (
    "id" UUID NOT NULL,
    "organization_id" UUID NOT NULL,
    "project_id" UUID NOT NULL,
    "unit_id" UUID NOT NULL,
    "from_booking_id" UUID NOT NULL,
    "to_booking_id" UUID NOT NULL,
    "from_party_id" UUID NOT NULL,
    "to_party_id" UUID NOT NULL,
    "transferred_on" DATE NOT NULL,
    "transfer_charges_paise" BIGINT NOT NULL DEFAULT 0,
    "charge_payer" "TransferChargePayer" NOT NULL,
    "ledger_carried_forward_paise" BIGINT NOT NULL DEFAULT 0,
    "approval_request_id" UUID,
    "journal_entry_id" UUID,
    "notes" TEXT,
    "created_at" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "created_by_id" UUID,

    CONSTRAINT "booking_transfers_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "demand_schedule_items" (
    "id" UUID NOT NULL,
    "organization_id" UUID NOT NULL,
    "project_id" UUID NOT NULL,
    "booking_id" UUID NOT NULL,
    "sort_order" INTEGER NOT NULL,
    "milestone" "DemandMilestone" NOT NULL,
    "custom_label" TEXT,
    "percent" DECIMAL(8,4) NOT NULL,
    "due_on" DATE,
    "base_paise" BIGINT NOT NULL,
    "cgst_paise" BIGINT NOT NULL DEFAULT 0,
    "sgst_paise" BIGINT NOT NULL DEFAULT 0,
    "igst_paise" BIGINT NOT NULL DEFAULT 0,
    "cess_paise" BIGINT NOT NULL DEFAULT 0,
    "total_paise" BIGINT NOT NULL,
    "created_at" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "updated_at" TIMESTAMP(3) NOT NULL,
    "deleted_at" TIMESTAMP(3),

    CONSTRAINT "demand_schedule_items_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "demand_notes" (
    "id" UUID NOT NULL,
    "organization_id" UUID NOT NULL,
    "project_id" UUID NOT NULL,
    "booking_id" UUID NOT NULL,
    "schedule_item_id" UUID,
    "gst_rate_id" UUID,
    "demand_number" TEXT NOT NULL,
    "status" "DemandStatus" NOT NULL DEFAULT 'RAISED',
    "raised_on" DATE NOT NULL,
    "due_on" DATE NOT NULL,
    "supply_type" "SupplyType" NOT NULL,
    "place_of_supply_state_code" TEXT NOT NULL,
    "base_paise" BIGINT NOT NULL,
    "cgst_paise" BIGINT NOT NULL DEFAULT 0,
    "sgst_paise" BIGINT NOT NULL DEFAULT 0,
    "igst_paise" BIGINT NOT NULL DEFAULT 0,
    "cess_paise" BIGINT NOT NULL DEFAULT 0,
    "round_off_paise" BIGINT NOT NULL DEFAULT 0,
    "total_paise" BIGINT NOT NULL,
    "created_at" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "updated_at" TIMESTAMP(3) NOT NULL,
    "deleted_at" TIMESTAMP(3),
    "created_by_id" UUID,

    CONSTRAINT "demand_notes_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "interest_rules" (
    "id" UUID NOT NULL,
    "organization_id" UUID NOT NULL,
    "project_id" UUID,
    "annual_rate_percent" DECIMAL(8,4) NOT NULL,
    "grace_days" INTEGER NOT NULL DEFAULT 0,
    "compound" BOOLEAN NOT NULL DEFAULT false,
    "effective_from" DATE NOT NULL,
    "effective_to" DATE,
    "created_at" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "updated_at" TIMESTAMP(3) NOT NULL,
    "deleted_at" TIMESTAMP(3),

    CONSTRAINT "interest_rules_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "interest_accruals" (
    "id" UUID NOT NULL,
    "organization_id" UUID NOT NULL,
    "project_id" UUID NOT NULL,
    "booking_id" UUID NOT NULL,
    "demand_note_id" UUID NOT NULL,
    "rule_id" UUID NOT NULL,
    "from_date" DATE NOT NULL,
    "to_date" DATE NOT NULL,
    "principal_paise" BIGINT NOT NULL,
    "annual_rate_percent" DECIMAL(8,4) NOT NULL,
    "day_count" INTEGER NOT NULL,
    "amount_paise" BIGINT NOT NULL,
    "formula_version" TEXT NOT NULL DEFAULT 'interest.simple.actual365.v1',
    "journal_entry_id" UUID,
    "reversal_of_id" UUID,
    "recorded_by_id" UUID NOT NULL,
    "created_at" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,

    CONSTRAINT "interest_accruals_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "receipts" (
    "id" UUID NOT NULL,
    "organization_id" UUID NOT NULL,
    "project_id" UUID NOT NULL,
    "booking_id" UUID NOT NULL,
    "payer_party_id" UUID,
    "bank_account_id" UUID,
    "recorded_by_id" UUID NOT NULL,
    "receipt_number" TEXT NOT NULL,
    "status" "ReceiptStatus" NOT NULL DEFAULT 'DRAFT',
    "received_on" DATE NOT NULL,
    "value_date" DATE,
    "channel" "MoneyChannel" NOT NULL,
    "instrument_reference" TEXT,
    "amount_paise" BIGINT NOT NULL,
    "buyer_tds_paise" BIGINT NOT NULL DEFAULT 0,
    "narration" TEXT,
    "journal_entry_id" UUID,
    "client_mutation_id" TEXT,
    "row_version" INTEGER NOT NULL DEFAULT 1,
    "created_at" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "updated_at" TIMESTAMP(3) NOT NULL,
    "deleted_at" TIMESTAMP(3),
    "created_by_id" UUID,

    CONSTRAINT "receipts_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "receipt_allocations" (
    "id" UUID NOT NULL,
    "organization_id" UUID NOT NULL,
    "receipt_id" UUID NOT NULL,
    "demand_note_id" UUID,
    "amount_paise" BIGINT NOT NULL,
    "created_at" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,

    CONSTRAINT "receipt_allocations_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "customer_statements" (
    "id" UUID NOT NULL,
    "organization_id" UUID NOT NULL,
    "project_id" UUID NOT NULL,
    "booking_id" UUID NOT NULL,
    "issued_by_id" UUID NOT NULL,
    "issued_on" DATE NOT NULL,
    "as_of" DATE NOT NULL,
    "opening_paise" BIGINT NOT NULL,
    "demands_paise" BIGINT NOT NULL,
    "interest_paise" BIGINT NOT NULL,
    "receipts_paise" BIGINT NOT NULL,
    "refunds_paise" BIGINT NOT NULL,
    "closing_paise" BIGINT NOT NULL,
    "formula_version" TEXT NOT NULL DEFAULT 'customer.ledger.v1',
    "created_at" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,

    CONSTRAINT "customer_statements_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "progress_updates" (
    "id" UUID NOT NULL,
    "organization_id" UUID NOT NULL,
    "project_id" UUID NOT NULL,
    "phase_id" UUID,
    "tower_id" UUID,
    "floor_id" UUID,
    "unit_id" UUID,
    "recorded_by_id" UUID NOT NULL,
    "taken_on" DATE NOT NULL,
    "caption" TEXT NOT NULL,
    "published_to_customers" BOOLEAN NOT NULL DEFAULT false,
    "client_mutation_id" TEXT,
    "created_at" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "updated_at" TIMESTAMP(3) NOT NULL,
    "deleted_at" TIMESTAMP(3),

    CONSTRAINT "progress_updates_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "capital_contributions" (
    "id" UUID NOT NULL,
    "organization_id" UUID NOT NULL,
    "project_id" UUID NOT NULL,
    "partner_party_id" UUID NOT NULL,
    "contributed_on" DATE NOT NULL,
    "instrument" "CapitalInstrument" NOT NULL,
    "amount_paise" BIGINT NOT NULL,
    "land_note" TEXT,
    "journal_entry_id" UUID,
    "created_at" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "created_by_id" UUID,

    CONSTRAINT "capital_contributions_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "profit_sharing_agreements" (
    "id" UUID NOT NULL,
    "organization_id" UUID NOT NULL,
    "project_id" UUID NOT NULL,
    "name" TEXT NOT NULL,
    "basis" "ShareBasis" NOT NULL,
    "status" "ComputationStatus" NOT NULL DEFAULT 'POSTED',
    "effective_from" DATE NOT NULL,
    "effective_to" DATE,
    "supersedes_id" UUID,
    "created_at" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "updated_at" TIMESTAMP(3) NOT NULL,
    "deleted_at" TIMESTAMP(3),
    "created_by_id" UUID,

    CONSTRAINT "profit_sharing_agreements_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "profit_sharing_rules" (
    "id" UUID NOT NULL,
    "organization_id" UUID NOT NULL,
    "project_id" UUID NOT NULL,
    "agreement_id" UUID NOT NULL,
    "partner_party_id" UUID NOT NULL,
    "priority" INTEGER NOT NULL,
    "share_percent" DECIMAL(8,4),
    "hurdle_rate_percent" DECIMAL(8,4),
    "fixed_amount_paise" BIGINT,
    "is_residual" BOOLEAN NOT NULL DEFAULT false,
    "participates_in_loss" BOOLEAN NOT NULL DEFAULT true,
    "absorbs_rounding" BOOLEAN NOT NULL DEFAULT false,
    "created_at" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "deleted_at" TIMESTAMP(3),

    CONSTRAINT "profit_sharing_rules_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "unit_allocations" (
    "id" UUID NOT NULL,
    "organization_id" UUID NOT NULL,
    "project_id" UUID NOT NULL,
    "unit_id" UUID NOT NULL,
    "partner_party_id" UUID NOT NULL,
    "share_percent" DECIMAL(8,4) NOT NULL DEFAULT 100,
    "reason" "AllocationReason" NOT NULL,
    "effective_from" DATE NOT NULL,
    "created_at" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "deleted_at" TIMESTAMP(3),

    CONSTRAINT "unit_allocations_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "share_computations" (
    "id" UUID NOT NULL,
    "organization_id" UUID NOT NULL,
    "project_id" UUID NOT NULL,
    "agreement_id" UUID NOT NULL,
    "computed_by_id" UUID NOT NULL,
    "computed_at" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "as_of" DATE NOT NULL,
    "profit_paise" BIGINT NOT NULL,
    "formula_version" TEXT NOT NULL,
    "status" "ComputationStatus" NOT NULL DEFAULT 'POSTED',
    "superseded_at" TIMESTAMP(3),
    "journal_entry_id" UUID,
    "notes" TEXT,

    CONSTRAINT "share_computations_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "share_ledger_entries" (
    "id" UUID NOT NULL,
    "organization_id" UUID NOT NULL,
    "project_id" UUID NOT NULL,
    "partner_party_id" UUID NOT NULL,
    "computation_id" UUID,
    "entry_type" "ShareEntryType" NOT NULL,
    "entry_date" DATE NOT NULL,
    "amount_paise" BIGINT NOT NULL,
    "narration" TEXT NOT NULL,
    "sequence" INTEGER NOT NULL,
    "prev_hash" TEXT NOT NULL,
    "entry_hash" TEXT NOT NULL,
    "created_at" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "created_by_id" UUID,

    CONSTRAINT "share_ledger_entries_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "material_categories" (
    "id" UUID NOT NULL,
    "organization_id" UUID NOT NULL,
    "parent_id" UUID,
    "name" TEXT NOT NULL,
    "created_at" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "updated_at" TIMESTAMP(3) NOT NULL,
    "deleted_at" TIMESTAMP(3),

    CONSTRAINT "material_categories_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "materials" (
    "id" UUID NOT NULL,
    "organization_id" UUID NOT NULL,
    "category_id" UUID,
    "gst_rate_id" UUID,
    "sku" TEXT NOT NULL,
    "name" TEXT NOT NULL,
    "uom" TEXT NOT NULL,
    "hsn_code" TEXT,
    "reorder_level" DECIMAL(18,4),
    "is_active" BOOLEAN NOT NULL DEFAULT true,
    "created_at" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "updated_at" TIMESTAMP(3) NOT NULL,
    "deleted_at" TIMESTAMP(3),

    CONSTRAINT "materials_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "stores" (
    "id" UUID NOT NULL,
    "organization_id" UUID NOT NULL,
    "project_id" UUID NOT NULL,
    "name" TEXT NOT NULL,
    "is_active" BOOLEAN NOT NULL DEFAULT true,
    "created_at" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "updated_at" TIMESTAMP(3) NOT NULL,
    "deleted_at" TIMESTAMP(3),

    CONSTRAINT "stores_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "indents" (
    "id" UUID NOT NULL,
    "organization_id" UUID NOT NULL,
    "project_id" UUID NOT NULL,
    "store_id" UUID,
    "requested_by_id" UUID NOT NULL,
    "indent_number" TEXT NOT NULL,
    "status" "IndentStatus" NOT NULL DEFAULT 'DRAFT',
    "needed_on" DATE,
    "notes" TEXT,
    "row_version" INTEGER NOT NULL DEFAULT 1,
    "created_at" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "updated_at" TIMESTAMP(3) NOT NULL,
    "deleted_at" TIMESTAMP(3),
    "created_by_id" UUID,

    CONSTRAINT "indents_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "indent_lines" (
    "id" UUID NOT NULL,
    "organization_id" UUID NOT NULL,
    "indent_id" UUID NOT NULL,
    "material_id" UUID,
    "boq_item_id" UUID,
    "description" TEXT NOT NULL,
    "quantity" DECIMAL(18,4) NOT NULL,
    "uom" TEXT NOT NULL,
    "created_at" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "deleted_at" TIMESTAMP(3),

    CONSTRAINT "indent_lines_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "vendor_quotes" (
    "id" UUID NOT NULL,
    "organization_id" UUID NOT NULL,
    "indent_id" UUID NOT NULL,
    "vendor_party_id" UUID NOT NULL,
    "quote_number" TEXT NOT NULL,
    "quote_date" DATE NOT NULL,
    "valid_until" DATE,
    "status" "QuoteStatus" NOT NULL DEFAULT 'RECEIVED',
    "notes" TEXT,
    "created_at" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "updated_at" TIMESTAMP(3) NOT NULL,
    "deleted_at" TIMESTAMP(3),

    CONSTRAINT "vendor_quotes_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "vendor_quote_lines" (
    "id" UUID NOT NULL,
    "organization_id" UUID NOT NULL,
    "quote_id" UUID NOT NULL,
    "indent_line_id" UUID NOT NULL,
    "quantity" DECIMAL(18,4) NOT NULL,
    "rate_rupees" DECIMAL(18,4) NOT NULL,
    "gst_rate_id" UUID,
    "amount_paise" BIGINT NOT NULL,
    "tax_paise" BIGINT NOT NULL DEFAULT 0,
    "created_at" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,

    CONSTRAINT "vendor_quote_lines_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "quote_comparisons" (
    "id" UUID NOT NULL,
    "organization_id" UUID NOT NULL,
    "indent_id" UUID NOT NULL,
    "compared_by_id" UUID NOT NULL,
    "selected_quote_id" UUID NOT NULL,
    "compared_at" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "reason" TEXT NOT NULL,

    CONSTRAINT "quote_comparisons_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "purchase_orders" (
    "id" UUID NOT NULL,
    "organization_id" UUID NOT NULL,
    "project_id" UUID NOT NULL,
    "vendor_party_id" UUID NOT NULL,
    "quote_id" UUID,
    "indent_id" UUID,
    "approval_request_id" UUID,
    "po_number" TEXT NOT NULL,
    "po_date" DATE NOT NULL,
    "status" "PurchaseOrderStatus" NOT NULL DEFAULT 'DRAFT',
    "expected_on" DATE,
    "notes" TEXT,
    "supersedes_id" UUID,
    "row_version" INTEGER NOT NULL DEFAULT 1,
    "created_at" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "updated_at" TIMESTAMP(3) NOT NULL,
    "deleted_at" TIMESTAMP(3),
    "created_by_id" UUID,

    CONSTRAINT "purchase_orders_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "purchase_order_lines" (
    "id" UUID NOT NULL,
    "organization_id" UUID NOT NULL,
    "purchase_order_id" UUID NOT NULL,
    "indent_line_id" UUID,
    "material_id" UUID NOT NULL,
    "description" TEXT NOT NULL,
    "quantity" DECIMAL(18,4) NOT NULL,
    "rate_rupees" DECIMAL(18,4) NOT NULL,
    "gst_rate_id" UUID,
    "amount_paise" BIGINT NOT NULL,
    "tax_paise" BIGINT NOT NULL DEFAULT 0,
    "created_at" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "deleted_at" TIMESTAMP(3),

    CONSTRAINT "purchase_order_lines_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "goods_receipts" (
    "id" UUID NOT NULL,
    "organization_id" UUID NOT NULL,
    "project_id" UUID NOT NULL,
    "store_id" UUID NOT NULL,
    "purchase_order_id" UUID,
    "vendor_party_id" UUID NOT NULL,
    "received_by_id" UUID NOT NULL,
    "grn_number" TEXT NOT NULL,
    "status" "GrnStatus" NOT NULL DEFAULT 'DRAFT',
    "received_on" DATE NOT NULL,
    "notes" TEXT,
    "client_mutation_id" TEXT,
    "row_version" INTEGER NOT NULL DEFAULT 1,
    "created_at" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "updated_at" TIMESTAMP(3) NOT NULL,
    "deleted_at" TIMESTAMP(3),
    "created_by_id" UUID,

    CONSTRAINT "goods_receipts_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "goods_receipt_lines" (
    "id" UUID NOT NULL,
    "organization_id" UUID NOT NULL,
    "goods_receipt_id" UUID NOT NULL,
    "purchase_order_line_id" UUID,
    "material_id" UUID NOT NULL,
    "received_quantity" DECIMAL(18,4) NOT NULL,
    "accepted_quantity" DECIMAL(18,4) NOT NULL,
    "rejected_quantity" DECIMAL(18,4) NOT NULL DEFAULT 0,
    "remarks" TEXT,
    "created_at" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,

    CONSTRAINT "goods_receipt_lines_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "vendor_invoices" (
    "id" UUID NOT NULL,
    "organization_id" UUID NOT NULL,
    "project_id" UUID,
    "vendor_party_id" UUID NOT NULL,
    "purchase_order_id" UUID,
    "approval_request_id" UUID,
    "tds_section_id" UUID,
    "journal_entry_id" UUID,
    "invoice_number" TEXT NOT NULL,
    "normalized_invoice_number" TEXT NOT NULL,
    "fingerprint" TEXT NOT NULL,
    "invoice_date" DATE NOT NULL,
    "status" "InvoiceStatus" NOT NULL DEFAULT 'DRAFT',
    "source" "InvoiceSource" NOT NULL DEFAULT 'INTERNAL',
    "expects_goods" BOOLEAN NOT NULL DEFAULT true,
    "supply_type" "SupplyType" NOT NULL,
    "place_of_supply_state_code" TEXT NOT NULL,
    "taxable_paise" BIGINT NOT NULL,
    "cgst_paise" BIGINT NOT NULL DEFAULT 0,
    "sgst_paise" BIGINT NOT NULL DEFAULT 0,
    "igst_paise" BIGINT NOT NULL DEFAULT 0,
    "cess_paise" BIGINT NOT NULL DEFAULT 0,
    "round_off_paise" BIGINT NOT NULL DEFAULT 0,
    "total_paise" BIGINT NOT NULL,
    "tds_paise" BIGINT NOT NULL DEFAULT 0,
    "net_payable_paise" BIGINT NOT NULL,
    "notes" TEXT,
    "row_version" INTEGER NOT NULL DEFAULT 1,
    "created_at" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "updated_at" TIMESTAMP(3) NOT NULL,
    "deleted_at" TIMESTAMP(3),
    "created_by_id" UUID,

    CONSTRAINT "vendor_invoices_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "vendor_invoice_lines" (
    "id" UUID NOT NULL,
    "organization_id" UUID NOT NULL,
    "invoice_id" UUID NOT NULL,
    "purchase_order_line_id" UUID,
    "material_id" UUID,
    "gst_rate_id" UUID,
    "description" TEXT NOT NULL,
    "quantity" DECIMAL(18,4) NOT NULL,
    "rate_rupees" DECIMAL(18,4) NOT NULL,
    "taxable_paise" BIGINT NOT NULL,
    "cgst_percent" DECIMAL(8,4) NOT NULL DEFAULT 0,
    "sgst_percent" DECIMAL(8,4) NOT NULL DEFAULT 0,
    "igst_percent" DECIMAL(8,4) NOT NULL DEFAULT 0,
    "cess_percent" DECIMAL(8,4) NOT NULL DEFAULT 0,
    "cgst_paise" BIGINT NOT NULL DEFAULT 0,
    "sgst_paise" BIGINT NOT NULL DEFAULT 0,
    "igst_paise" BIGINT NOT NULL DEFAULT 0,
    "cess_paise" BIGINT NOT NULL DEFAULT 0,
    "created_at" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,

    CONSTRAINT "vendor_invoice_lines_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "three_way_matches" (
    "id" UUID NOT NULL,
    "organization_id" UUID NOT NULL,
    "vendor_invoice_id" UUID NOT NULL,
    "purchase_order_id" UUID,
    "status" "MatchStatus" NOT NULL,
    "rate_variance_paise" BIGINT NOT NULL DEFAULT 0,
    "notes" TEXT,
    "matched_by_id" UUID,
    "matched_at" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,

    CONSTRAINT "three_way_matches_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "three_way_match_lines" (
    "id" UUID NOT NULL,
    "organization_id" UUID NOT NULL,
    "match_id" UUID NOT NULL,
    "invoice_line_id" UUID NOT NULL,
    "po_line_id" UUID,
    "grn_line_id" UUID,
    "invoice_qty" DECIMAL(18,4) NOT NULL,
    "po_qty" DECIMAL(18,4),
    "grn_qty" DECIMAL(18,4),
    "invoice_rate_rupees" DECIMAL(18,4),
    "po_rate_rupees" DECIMAL(18,4),
    "status" "MatchStatus" NOT NULL,

    CONSTRAINT "three_way_match_lines_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "stock_ledger_entries" (
    "id" UUID NOT NULL,
    "organization_id" UUID NOT NULL,
    "project_id" UUID NOT NULL,
    "store_id" UUID NOT NULL,
    "material_id" UUID NOT NULL,
    "movement" "StockMovement" NOT NULL,
    "quantity" DECIMAL(18,4) NOT NULL,
    "rate_rupees" DECIMAL(18,4),
    "value_paise" BIGINT,
    "average_rate_rupees" DECIMAL(18,6),
    "valuation_method" "ValuationMethod" NOT NULL DEFAULT 'WEIGHTED_AVERAGE',
    "transfer_group_id" UUID,
    "source_type" "RecordRef" NOT NULL,
    "source_id" UUID NOT NULL,
    "approval_request_id" UUID,
    "occurred_on" DATE NOT NULL,
    "sequence" INTEGER NOT NULL,
    "prev_hash" TEXT NOT NULL,
    "entry_hash" TEXT NOT NULL,
    "created_at" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "created_by_id" UUID,

    CONSTRAINT "stock_ledger_entries_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "material_issues" (
    "id" UUID NOT NULL,
    "organization_id" UUID NOT NULL,
    "project_id" UUID NOT NULL,
    "store_id" UUID NOT NULL,
    "work_order_id" UUID,
    "issued_by_id" UUID NOT NULL,
    "issued_on" DATE NOT NULL,
    "notes" TEXT,
    "client_mutation_id" TEXT,
    "created_at" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "updated_at" TIMESTAMP(3) NOT NULL,
    "deleted_at" TIMESTAMP(3),

    CONSTRAINT "material_issues_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "material_issue_lines" (
    "id" UUID NOT NULL,
    "organization_id" UUID NOT NULL,
    "issue_id" UUID NOT NULL,
    "material_id" UUID NOT NULL,
    "boq_item_id" UUID,
    "quantity" DECIMAL(18,4) NOT NULL,
    "wastage_quantity" DECIMAL(18,4) NOT NULL DEFAULT 0,
    "wastage_reason" TEXT,
    "created_at" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,

    CONSTRAINT "material_issue_lines_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "workers" (
    "id" UUID NOT NULL,
    "organization_id" UUID NOT NULL,
    "contractor_party_id" UUID,
    "name" TEXT NOT NULL,
    "skill" TEXT,
    "phone_e164" TEXT,
    "daily_wage_paise" BIGINT,
    "is_active" BOOLEAN NOT NULL DEFAULT true,
    "created_at" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "updated_at" TIMESTAMP(3) NOT NULL,
    "deleted_at" TIMESTAMP(3),

    CONSTRAINT "workers_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "labour_attendances" (
    "id" UUID NOT NULL,
    "organization_id" UUID NOT NULL,
    "project_id" UUID NOT NULL,
    "worker_id" UUID NOT NULL,
    "recorded_by_id" UUID NOT NULL,
    "work_date" DATE NOT NULL,
    "status" "AttendanceStatus" NOT NULL,
    "overtime_hours" DECIMAL(8,2) NOT NULL DEFAULT 0,
    "daily_wage_paise" BIGINT NOT NULL,
    "wage_paise" BIGINT NOT NULL,
    "formula_version" TEXT NOT NULL DEFAULT 'attendance.wage.v1',
    "notes" TEXT,
    "client_mutation_id" TEXT,
    "created_at" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "updated_at" TIMESTAMP(3) NOT NULL,
    "deleted_at" TIMESTAMP(3),

    CONSTRAINT "labour_attendances_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "work_orders" (
    "id" UUID NOT NULL,
    "organization_id" UUID NOT NULL,
    "project_id" UUID NOT NULL,
    "contractor_party_id" UUID NOT NULL,
    "tds_section_id" UUID,
    "approval_request_id" UUID,
    "wo_number" TEXT NOT NULL,
    "title" TEXT NOT NULL,
    "status" "WorkOrderStatus" NOT NULL DEFAULT 'DRAFT',
    "retention_percent" DECIMAL(8,4) NOT NULL,
    "start_on" DATE,
    "end_on" DATE,
    "row_version" INTEGER NOT NULL DEFAULT 1,
    "created_at" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "updated_at" TIMESTAMP(3) NOT NULL,
    "deleted_at" TIMESTAMP(3),
    "created_by_id" UUID,

    CONSTRAINT "work_orders_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "work_order_lines" (
    "id" UUID NOT NULL,
    "organization_id" UUID NOT NULL,
    "work_order_id" UUID NOT NULL,
    "boq_item_id" UUID,
    "description" TEXT NOT NULL,
    "uom" TEXT NOT NULL,
    "quantity" DECIMAL(18,4) NOT NULL,
    "rate_rupees" DECIMAL(18,4) NOT NULL,
    "amount_paise" BIGINT NOT NULL,
    "created_at" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "deleted_at" TIMESTAMP(3),

    CONSTRAINT "work_order_lines_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "measurement_entries" (
    "id" UUID NOT NULL,
    "organization_id" UUID NOT NULL,
    "project_id" UUID NOT NULL,
    "work_order_line_id" UUID NOT NULL,
    "measured_by_id" UUID NOT NULL,
    "checked_by_id" UUID,
    "status" "MeasurementStatus" NOT NULL DEFAULT 'DRAFT',
    "measured_on" DATE NOT NULL,
    "mb_book" TEXT NOT NULL,
    "mb_page" TEXT NOT NULL,
    "location_note" TEXT NOT NULL,
    "quantity" DECIMAL(18,4) NOT NULL,
    "uom" TEXT NOT NULL,
    "remarks" TEXT,
    "client_mutation_id" TEXT,
    "created_at" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "updated_at" TIMESTAMP(3) NOT NULL,
    "deleted_at" TIMESTAMP(3),

    CONSTRAINT "measurement_entries_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "ra_bills" (
    "id" UUID NOT NULL,
    "organization_id" UUID NOT NULL,
    "project_id" UUID NOT NULL,
    "work_order_id" UUID NOT NULL,
    "approval_request_id" UUID,
    "tds_section_id" UUID,
    "journal_entry_id" UUID,
    "bill_number" TEXT NOT NULL,
    "status" "RaBillStatus" NOT NULL DEFAULT 'DRAFT',
    "period_start" DATE NOT NULL,
    "period_end" DATE NOT NULL,
    "supply_type" "SupplyType" NOT NULL,
    "place_of_supply_state_code" TEXT NOT NULL,
    "gross_paise" BIGINT NOT NULL,
    "cgst_paise" BIGINT NOT NULL DEFAULT 0,
    "sgst_paise" BIGINT NOT NULL DEFAULT 0,
    "igst_paise" BIGINT NOT NULL DEFAULT 0,
    "cess_paise" BIGINT NOT NULL DEFAULT 0,
    "round_off_paise" BIGINT NOT NULL DEFAULT 0,
    "retention_paise" BIGINT NOT NULL DEFAULT 0,
    "advance_recovery_paise" BIGINT NOT NULL DEFAULT 0,
    "tds_paise" BIGINT NOT NULL DEFAULT 0,
    "other_deduction_paise" BIGINT NOT NULL DEFAULT 0,
    "net_payable_paise" BIGINT NOT NULL,
    "row_version" INTEGER NOT NULL DEFAULT 1,
    "created_at" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "updated_at" TIMESTAMP(3) NOT NULL,
    "deleted_at" TIMESTAMP(3),
    "created_by_id" UUID,

    CONSTRAINT "ra_bills_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "ra_bill_lines" (
    "id" UUID NOT NULL,
    "organization_id" UUID NOT NULL,
    "ra_bill_id" UUID NOT NULL,
    "work_order_line_id" UUID NOT NULL,
    "measurement_entry_id" UUID,
    "quantity" DECIMAL(18,4) NOT NULL,
    "rate_rupees" DECIMAL(18,4) NOT NULL,
    "amount_paise" BIGINT NOT NULL,
    "created_at" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,

    CONSTRAINT "ra_bill_lines_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "retention_entries" (
    "id" UUID NOT NULL,
    "organization_id" UUID NOT NULL,
    "project_id" UUID NOT NULL,
    "contractor_party_id" UUID NOT NULL,
    "ra_bill_id" UUID,
    "journal_entry_id" UUID,
    "action" "RetentionAction" NOT NULL,
    "amount_paise" BIGINT NOT NULL,
    "entry_date" DATE NOT NULL,
    "created_at" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "created_by_id" UUID,

    CONSTRAINT "retention_entries_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "contractor_advances" (
    "id" UUID NOT NULL,
    "organization_id" UUID NOT NULL,
    "project_id" UUID NOT NULL,
    "work_order_id" UUID NOT NULL,
    "contractor_party_id" UUID NOT NULL,
    "journal_entry_id" UUID,
    "status" "AdvanceStatus" NOT NULL DEFAULT 'OPEN',
    "advanced_on" DATE NOT NULL,
    "amount_paise" BIGINT NOT NULL,
    "created_at" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "updated_at" TIMESTAMP(3) NOT NULL,
    "created_by_id" UUID,

    CONSTRAINT "contractor_advances_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "advance_recoveries" (
    "id" UUID NOT NULL,
    "organization_id" UUID NOT NULL,
    "project_id" UUID NOT NULL,
    "advance_id" UUID NOT NULL,
    "ra_bill_id" UUID NOT NULL,
    "journal_entry_id" UUID,
    "recovered_on" DATE NOT NULL,
    "amount_paise" BIGINT NOT NULL,
    "created_at" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "created_by_id" UUID,

    CONSTRAINT "advance_recoveries_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "gl_accounts" (
    "id" UUID NOT NULL,
    "organization_id" UUID NOT NULL,
    "parent_id" UUID,
    "code" TEXT NOT NULL,
    "name" TEXT NOT NULL,
    "account_type" "AccountType" NOT NULL,
    "normal_balance" "NormalBalance" NOT NULL,
    "is_group" BOOLEAN NOT NULL DEFAULT false,
    "is_active" BOOLEAN NOT NULL DEFAULT true,
    "requires_project" BOOLEAN NOT NULL DEFAULT false,
    "requires_cost_centre" BOOLEAN NOT NULL DEFAULT false,
    "row_version" INTEGER NOT NULL DEFAULT 1,
    "created_at" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "updated_at" TIMESTAMP(3) NOT NULL,
    "deleted_at" TIMESTAMP(3),

    CONSTRAINT "gl_accounts_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "journal_entries" (
    "id" UUID NOT NULL,
    "organization_id" UUID NOT NULL,
    "period_id" UUID NOT NULL,
    "posted_by_id" UUID,
    "entry_number" TEXT NOT NULL,
    "entry_date" DATE NOT NULL,
    "narration" TEXT NOT NULL,
    "source" "JournalSource" NOT NULL,
    "source_id" UUID,
    "status" "JournalStatus" NOT NULL DEFAULT 'DRAFT',
    "reversal_of_id" UUID,
    "sequence" INTEGER,
    "prev_hash" TEXT,
    "entry_hash" TEXT,
    "idempotency_key" TEXT,
    "posted_at" TIMESTAMP(3),
    "row_version" INTEGER NOT NULL DEFAULT 1,
    "created_at" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "updated_at" TIMESTAMP(3) NOT NULL,
    "deleted_at" TIMESTAMP(3),
    "created_by_id" UUID,

    CONSTRAINT "journal_entries_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "journal_lines" (
    "id" UUID NOT NULL,
    "organization_id" UUID NOT NULL,
    "entry_id" UUID NOT NULL,
    "gl_account_id" UUID NOT NULL,
    "line_number" INTEGER NOT NULL,
    "debit_paise" BIGINT NOT NULL DEFAULT 0,
    "credit_paise" BIGINT NOT NULL DEFAULT 0,
    "project_id" UUID,
    "cost_centre_id" UUID,
    "unit_id" UUID,
    "party_id" UUID,
    "narration" TEXT,

    CONSTRAINT "journal_lines_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "bank_accounts" (
    "id" UUID NOT NULL,
    "organization_id" UUID NOT NULL,
    "gl_account_id" UUID NOT NULL,
    "display_name" TEXT NOT NULL,
    "bank_name" TEXT,
    "account_number" TEXT,
    "ifsc" TEXT,
    "is_cash" BOOLEAN NOT NULL DEFAULT false,
    "is_active" BOOLEAN NOT NULL DEFAULT true,
    "created_at" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "updated_at" TIMESTAMP(3) NOT NULL,
    "deleted_at" TIMESTAMP(3),

    CONSTRAINT "bank_accounts_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "bank_statement_imports" (
    "id" UUID NOT NULL,
    "organization_id" UUID NOT NULL,
    "bank_account_id" UUID NOT NULL,
    "import_batch_id" UUID,
    "document_id" UUID,
    "imported_by_id" UUID NOT NULL,
    "source_file_name" TEXT NOT NULL,
    "imported_at" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "row_count" INTEGER NOT NULL DEFAULT 0,

    CONSTRAINT "bank_statement_imports_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "bank_statement_lines" (
    "id" UUID NOT NULL,
    "organization_id" UUID NOT NULL,
    "import_id" UUID NOT NULL,
    "bank_account_id" UUID NOT NULL,
    "line_number" INTEGER NOT NULL,
    "txn_date" DATE NOT NULL,
    "value_date" DATE,
    "signed_amount_paise" BIGINT NOT NULL,
    "narration" TEXT NOT NULL,
    "reference" TEXT,
    "balance_paise" BIGINT,
    "fingerprint" TEXT NOT NULL,
    "match_status" "BankMatchStatus" NOT NULL DEFAULT 'UNMATCHED',

    CONSTRAINT "bank_statement_lines_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "reconciliation_matches" (
    "id" UUID NOT NULL,
    "organization_id" UUID NOT NULL,
    "statement_line_id" UUID NOT NULL,
    "journal_line_id" UUID NOT NULL,
    "matched_by_id" UUID NOT NULL,
    "amount_paise" BIGINT NOT NULL,
    "matched_at" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "deleted_at" TIMESTAMP(3),

    CONSTRAINT "reconciliation_matches_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "budgets" (
    "id" UUID NOT NULL,
    "organization_id" UUID NOT NULL,
    "project_id" UUID NOT NULL,
    "name" TEXT NOT NULL,
    "status" "BudgetStatus" NOT NULL DEFAULT 'DRAFT',
    "version" INTEGER NOT NULL DEFAULT 1,
    "supersedes_id" UUID,
    "approved_at" TIMESTAMP(3),
    "row_version" INTEGER NOT NULL DEFAULT 1,
    "created_at" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "updated_at" TIMESTAMP(3) NOT NULL,
    "deleted_at" TIMESTAMP(3),
    "created_by_id" UUID,

    CONSTRAINT "budgets_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "budget_lines" (
    "id" UUID NOT NULL,
    "organization_id" UUID NOT NULL,
    "budget_id" UUID NOT NULL,
    "cost_centre_id" UUID,
    "gl_account_id" UUID,
    "boq_item_id" UUID,
    "amount_paise" BIGINT NOT NULL,
    "notes" TEXT,
    "created_at" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "deleted_at" TIMESTAMP(3),

    CONSTRAINT "budget_lines_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "loans" (
    "id" UUID NOT NULL,
    "organization_id" UUID NOT NULL,
    "project_id" UUID NOT NULL,
    "lender_party_id" UUID NOT NULL,
    "gl_account_id" UUID,
    "name" TEXT NOT NULL,
    "kind" "LoanKind" NOT NULL,
    "status" "LoanStatus" NOT NULL DEFAULT 'DRAFT',
    "repayment_style" "LoanRepaymentStyle" NOT NULL,
    "sanctioned_paise" BIGINT NOT NULL,
    "annual_rate_percent" DECIMAL(8,4) NOT NULL,
    "tenure_months" INTEGER,
    "starts_on" DATE,
    "formula_version" TEXT NOT NULL DEFAULT 'emi.reducing.monthly.v1',
    "row_version" INTEGER NOT NULL DEFAULT 1,
    "created_at" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "updated_at" TIMESTAMP(3) NOT NULL,
    "deleted_at" TIMESTAMP(3),
    "created_by_id" UUID,

    CONSTRAINT "loans_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "loan_interest_accruals" (
    "id" UUID NOT NULL,
    "organization_id" UUID NOT NULL,
    "loan_id" UUID NOT NULL,
    "recorded_by_id" UUID NOT NULL,
    "from_date" DATE NOT NULL,
    "to_date" DATE NOT NULL,
    "principal_paise" BIGINT NOT NULL,
    "annual_rate_percent" DECIMAL(8,4) NOT NULL,
    "day_count" INTEGER NOT NULL,
    "amount_paise" BIGINT NOT NULL,
    "formula_version" TEXT NOT NULL DEFAULT 'loan.simple.actual365.v1',
    "journal_entry_id" UUID,
    "reversal_of_id" UUID,
    "created_at" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,

    CONSTRAINT "loan_interest_accruals_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "loan_transactions" (
    "id" UUID NOT NULL,
    "organization_id" UUID NOT NULL,
    "loan_id" UUID NOT NULL,
    "journal_entry_id" UUID,
    "txn_type" "LoanTxnType" NOT NULL,
    "txn_date" DATE NOT NULL,
    "principal_paise" BIGINT NOT NULL DEFAULT 0,
    "interest_paise" BIGINT NOT NULL DEFAULT 0,
    "fee_paise" BIGINT NOT NULL DEFAULT 0,
    "created_at" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "created_by_id" UUID,

    CONSTRAINT "loan_transactions_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "emi_schedules" (
    "id" UUID NOT NULL,
    "organization_id" UUID NOT NULL,
    "loan_id" UUID NOT NULL,
    "version" INTEGER NOT NULL,
    "generated_at" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "formula_version" TEXT NOT NULL DEFAULT 'emi.reducing.monthly.v1',
    "annual_rate_percent" DECIMAL(8,4) NOT NULL,
    "principal_paise" BIGINT NOT NULL,
    "tenure_months" INTEGER NOT NULL,
    "contractual_emi_paise" BIGINT NOT NULL,
    "status" "ComputationStatus" NOT NULL DEFAULT 'POSTED',
    "superseded_at" TIMESTAMP(3),
    "supersedes_id" UUID,

    CONSTRAINT "emi_schedules_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "emi_schedule_lines" (
    "id" UUID NOT NULL,
    "organization_id" UUID NOT NULL,
    "schedule_id" UUID NOT NULL,
    "loan_transaction_id" UUID,
    "installment_number" INTEGER NOT NULL,
    "due_on" DATE NOT NULL,
    "opening_principal_paise" BIGINT NOT NULL,
    "principal_paise" BIGINT NOT NULL,
    "interest_paise" BIGINT NOT NULL,
    "emi_paise" BIGINT NOT NULL,
    "closing_principal_paise" BIGINT NOT NULL,
    "status" "EmiStatus" NOT NULL DEFAULT 'DUE',

    CONSTRAINT "emi_schedule_lines_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "payments" (
    "id" UUID NOT NULL,
    "organization_id" UUID NOT NULL,
    "project_id" UUID,
    "party_id" UUID NOT NULL,
    "bank_account_id" UUID,
    "prepared_by_id" UUID NOT NULL,
    "approval_request_id" UUID,
    "journal_entry_id" UUID,
    "purpose" "PaymentPurpose" NOT NULL,
    "status" "PaymentStatus" NOT NULL DEFAULT 'DRAFT',
    "payment_date" DATE NOT NULL,
    "channel" "MoneyChannel" NOT NULL,
    "instrument_reference" TEXT,
    "amount_paise" BIGINT NOT NULL,
    "narration" TEXT,
    "idempotency_key" TEXT,
    "row_version" INTEGER NOT NULL DEFAULT 1,
    "created_at" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "updated_at" TIMESTAMP(3) NOT NULL,
    "deleted_at" TIMESTAMP(3),

    CONSTRAINT "payments_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "payment_allocations" (
    "id" UUID NOT NULL,
    "organization_id" UUID NOT NULL,
    "payment_id" UUID NOT NULL,
    "amount_paise" BIGINT NOT NULL,
    "vendor_invoice_id" UUID,
    "ra_bill_id" UUID,
    "loan_transaction_id" UUID,
    "contractor_advance_id" UUID,
    "booking_cancellation_id" UUID,
    "retention_entry_id" UUID,
    "narration" TEXT,
    "created_at" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,

    CONSTRAINT "payment_allocations_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "payment_source_links" (
    "id" UUID NOT NULL,
    "organization_id" UUID NOT NULL,
    "payment_id" UUID NOT NULL,
    "document_id" UUID NOT NULL,
    "created_at" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,

    CONSTRAINT "payment_source_links_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "tally_ledger_maps" (
    "id" UUID NOT NULL,
    "organization_id" UUID NOT NULL,
    "tally_ledger_name" TEXT NOT NULL,
    "gl_account_id" UUID NOT NULL,

    CONSTRAINT "tally_ledger_maps_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "import_batches" (
    "id" UUID NOT NULL,
    "organization_id" UUID NOT NULL,
    "created_by_id" UUID NOT NULL,
    "document_id" UUID,
    "kind" "ImportKind" NOT NULL,
    "status" "ImportStatus" NOT NULL DEFAULT 'PENDING',
    "row_count" INTEGER NOT NULL DEFAULT 0,
    "error_count" INTEGER NOT NULL DEFAULT 0,
    "error_report" JSONB,
    "created_at" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "updated_at" TIMESTAMP(3) NOT NULL,

    CONSTRAINT "import_batches_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "documents" (
    "id" UUID NOT NULL,
    "organization_id" UUID NOT NULL,
    "uploaded_by_id" UUID NOT NULL,
    "entity_type" "RecordRef" NOT NULL,
    "entity_id" UUID NOT NULL,
    "file_name" TEXT NOT NULL,
    "mime_type" TEXT NOT NULL,
    "byte_size" INTEGER NOT NULL,
    "storage_key" TEXT NOT NULL,
    "sha256" TEXT NOT NULL,
    "ocr_status" "OcrStatus" NOT NULL DEFAULT 'PENDING',
    "created_at" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "deleted_at" TIMESTAMP(3),

    CONSTRAINT "documents_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "ocr_extractions" (
    "id" UUID NOT NULL,
    "organization_id" UUID NOT NULL,
    "document_id" UUID NOT NULL,
    "provider" TEXT NOT NULL,
    "raw_text" TEXT,
    "fields" JSONB,
    "confidence" DECIMAL(5,4),
    "extracted_at" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,

    CONSTRAINT "ocr_extractions_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "exception_rules" (
    "id" UUID NOT NULL,
    "organization_id" UUID NOT NULL,
    "code" "ExceptionCode" NOT NULL,
    "is_enabled" BOOLEAN NOT NULL DEFAULT true,
    "severity" "ExceptionSeverity" NOT NULL,
    "plain_language" TEXT NOT NULL,
    "round_figure_multiple_paise" BIGINT,
    "round_figure_min_paise" BIGINT,
    "flag_saturday" BOOLEAN NOT NULL DEFAULT true,
    "flag_sunday" BOOLEAN NOT NULL DEFAULT true,
    "area_variance_percent" DECIMAL(8,4),
    "wastage_variance_percent" DECIMAL(8,4),
    "unmatched_after_days" INTEGER,
    "approval_overdue_hours" INTEGER,
    "created_at" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "updated_at" TIMESTAMP(3) NOT NULL,

    CONSTRAINT "exception_rules_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "exception_items" (
    "id" UUID NOT NULL,
    "organization_id" UUID NOT NULL,
    "project_id" UUID,
    "rule_id" UUID,
    "code" "ExceptionCode" NOT NULL,
    "severity" "ExceptionSeverity" NOT NULL,
    "status" "ExceptionStatus" NOT NULL DEFAULT 'OPEN',
    "title" TEXT NOT NULL,
    "detail" TEXT,
    "entity_type" "RecordRef" NOT NULL,
    "entity_id" UUID NOT NULL,
    "related_entity_type" "RecordRef",
    "related_entity_id" UUID,
    "matched_on" TEXT,
    "detected_at" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "acknowledged_by_id" UUID,
    "acknowledged_at" TIMESTAMP(3),
    "resolved_by_id" UUID,
    "resolved_at" TIMESTAMP(3),
    "resolution_note" TEXT,

    CONSTRAINT "exception_items_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "notifications" (
    "id" UUID NOT NULL,
    "organization_id" UUID NOT NULL,
    "user_id" UUID NOT NULL,
    "channel" "NotificationChannel" NOT NULL,
    "locale" "Locale" NOT NULL DEFAULT 'EN',
    "template_key" TEXT NOT NULL,
    "payload" JSONB NOT NULL,
    "status" "NotificationStatus" NOT NULL DEFAULT 'QUEUED',
    "error" TEXT,
    "scheduled_for" TIMESTAMP(3),
    "sent_at" TIMESTAMP(3),
    "created_at" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,

    CONSTRAINT "notifications_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "sync_mutations" (
    "id" UUID NOT NULL,
    "organization_id" UUID NOT NULL,
    "device_id" UUID NOT NULL,
    "client_mutation_id" TEXT NOT NULL,
    "entity_type" "OfflineEntity" NOT NULL,
    "entity_id" UUID,
    "payload" JSONB NOT NULL,
    "status" "SyncStatus" NOT NULL DEFAULT 'PENDING',
    "rejection_reason" TEXT,
    "received_at" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "applied_at" TIMESTAMP(3),

    CONSTRAINT "sync_mutations_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "search_documents" (
    "id" UUID NOT NULL,
    "organization_id" UUID NOT NULL,
    "entity_type" "RecordRef" NOT NULL,
    "entity_id" UUID NOT NULL,
    "title" TEXT NOT NULL,
    "subtitle" TEXT,
    "keywords" TEXT NOT NULL,
    "updated_at" TIMESTAMP(3) NOT NULL,

    CONSTRAINT "search_documents_pkey" PRIMARY KEY ("id")
);

-- CreateIndex
CREATE UNIQUE INDEX "organizations_slug_key" ON "organizations"("slug");

-- CreateIndex
CREATE UNIQUE INDEX "users_email_key" ON "users"("email");

-- CreateIndex
CREATE UNIQUE INDEX "auth_accounts_provider_provider_account_id_key" ON "auth_accounts"("provider", "provider_account_id");

-- CreateIndex
CREATE UNIQUE INDEX "auth_sessions_session_token_key" ON "auth_sessions"("session_token");

-- CreateIndex
CREATE UNIQUE INDEX "auth_verification_tokens_token_key" ON "auth_verification_tokens"("token");

-- CreateIndex
CREATE UNIQUE INDEX "auth_verification_tokens_identifier_token_key" ON "auth_verification_tokens"("identifier", "token");

-- CreateIndex
CREATE INDEX "memberships_org_user_idx" ON "memberships"("organization_id", "user_id");

-- CreateIndex
CREATE INDEX "memberships_party_idx" ON "memberships"("party_id");

-- CreateIndex
CREATE INDEX "project_assignments_org_idx" ON "project_assignments"("organization_id");

-- CreateIndex
CREATE INDEX "project_assignments_user_idx" ON "project_assignments"("user_id");

-- CreateIndex
CREATE INDEX "project_assignments_project_idx" ON "project_assignments"("project_id");

-- CreateIndex
CREATE INDEX "devices_org_user_idx" ON "devices"("organization_id", "user_id");

-- CreateIndex
CREATE INDEX "audit_events_entity_idx" ON "audit_events"("organization_id", "entity_type", "entity_id");

-- CreateIndex
CREATE INDEX "audit_events_actor_idx" ON "audit_events"("actor_id");

-- CreateIndex
CREATE UNIQUE INDEX "audit_events_org_seq" ON "audit_events"("organization_id", "sequence");

-- CreateIndex
CREATE UNIQUE INDEX "chain_heads_org_chain" ON "chain_heads"("organization_id", "chain");

-- CreateIndex
CREATE INDEX "approval_policies_org_entity_idx" ON "approval_policies"("organization_id", "entity_type");

-- CreateIndex
CREATE INDEX "approval_requests_entity_idx" ON "approval_requests"("organization_id", "entity_type", "entity_id");

-- CreateIndex
CREATE INDEX "approval_requests_requester_idx" ON "approval_requests"("requested_by_id");

-- CreateIndex
CREATE INDEX "approval_actions_request_idx" ON "approval_actions"("request_id");

-- CreateIndex
CREATE UNIQUE INDEX "fiscal_years_org_name" ON "fiscal_years"("organization_id", "name");

-- CreateIndex
CREATE INDEX "accounting_periods_fy_idx" ON "accounting_periods"("fiscal_year_id");

-- CreateIndex
CREATE UNIQUE INDEX "accounting_periods_org_start" ON "accounting_periods"("organization_id", "starts_on");

-- CreateIndex
CREATE INDEX "period_lock_events_period_idx" ON "period_lock_events"("period_id");

-- CreateIndex
CREATE UNIQUE INDEX "tds_sections_code_key" ON "tds_sections"("code");

-- CreateIndex
CREATE UNIQUE INDEX "document_sequences_org_type_fy" ON "document_sequences"("organization_id", "doc_type", "fiscal_year_id");

-- CreateIndex
CREATE INDEX "parties_org_pan_idx" ON "parties"("organization_id", "pan_normalized");

-- CreateIndex
CREATE INDEX "parties_org_gstin_idx" ON "parties"("organization_id", "gstin_normalized");

-- CreateIndex
CREATE INDEX "parties_org_name_idx" ON "parties"("organization_id", "display_name");

-- CreateIndex
CREATE INDEX "party_addresses_party_idx" ON "party_addresses"("party_id");

-- CreateIndex
CREATE INDEX "party_bank_accounts_fingerprint_idx" ON "party_bank_accounts"("organization_id", "fingerprint");

-- CreateIndex
CREATE INDEX "party_bank_accounts_party_idx" ON "party_bank_accounts"("party_id");

-- CreateIndex
CREATE INDEX "party_contacts_org_phone_idx" ON "party_contacts"("organization_id", "phone_e164");

-- CreateIndex
CREATE INDEX "party_contacts_party_idx" ON "party_contacts"("party_id");

-- CreateIndex
CREATE UNIQUE INDEX "vendor_profiles_party_id_key" ON "vendor_profiles"("party_id");

-- CreateIndex
CREATE INDEX "vendor_profiles_org_idx" ON "vendor_profiles"("organization_id");

-- CreateIndex
CREATE UNIQUE INDEX "contractor_profiles_party_id_key" ON "contractor_profiles"("party_id");

-- CreateIndex
CREATE INDEX "projects_org_status_idx" ON "projects"("organization_id", "status");

-- CreateIndex
CREATE UNIQUE INDEX "projects_org_code" ON "projects"("organization_id", "code");

-- CreateIndex
CREATE INDEX "project_phases_org_idx" ON "project_phases"("organization_id");

-- CreateIndex
CREATE UNIQUE INDEX "project_phases_project_sort" ON "project_phases"("project_id", "sort_order");

-- CreateIndex
CREATE INDEX "towers_org_idx" ON "towers"("organization_id");

-- CreateIndex
CREATE UNIQUE INDEX "towers_project_name" ON "towers"("project_id", "name");

-- CreateIndex
CREATE INDEX "floors_org_idx" ON "floors"("organization_id");

-- CreateIndex
CREATE UNIQUE INDEX "floors_tower_level" ON "floors"("tower_id", "level_number");

-- CreateIndex
CREATE INDEX "units_org_project_idx" ON "units"("organization_id", "project_id");

-- CreateIndex
CREATE INDEX "units_floor_idx" ON "units"("floor_id");

-- CreateIndex
CREATE INDEX "units_project_status_idx" ON "units"("project_id", "status");

-- CreateIndex
CREATE INDEX "unit_area_revisions_unit_idx" ON "unit_area_revisions"("unit_id", "recorded_at");

-- CreateIndex
CREATE INDEX "cost_centres_org_idx" ON "cost_centres"("organization_id");

-- CreateIndex
CREATE UNIQUE INDEX "cost_centres_project_code" ON "cost_centres"("project_id", "code");

-- CreateIndex
CREATE INDEX "boq_items_org_idx" ON "boq_items"("organization_id");

-- CreateIndex
CREATE UNIQUE INDEX "boq_items_project_code" ON "boq_items"("project_id", "code");

-- CreateIndex
CREATE INDEX "leads_org_status_idx" ON "leads"("organization_id", "status");

-- CreateIndex
CREATE INDEX "leads_assignee_idx" ON "leads"("assigned_to_id");

-- CreateIndex
CREATE INDEX "lead_followups_org_due_idx" ON "lead_followups"("organization_id", "due_on");

-- CreateIndex
CREATE INDEX "lead_followups_lead_idx" ON "lead_followups"("lead_id");

-- CreateIndex
CREATE INDEX "site_visits_project_idx" ON "site_visits"("project_id", "scheduled_start");

-- CreateIndex
CREATE INDEX "site_visits_lead_idx" ON "site_visits"("lead_id");

-- CreateIndex
CREATE INDEX "lead_activities_lead_idx" ON "lead_activities"("lead_id", "happened_at");

-- CreateIndex
CREATE INDEX "bookings_project_status_idx" ON "bookings"("project_id", "status");

-- CreateIndex
CREATE INDEX "bookings_unit_idx" ON "bookings"("unit_id");

-- CreateIndex
CREATE UNIQUE INDEX "bookings_org_number" ON "bookings"("organization_id", "booking_number");

-- CreateIndex
CREATE INDEX "booking_customers_org_idx" ON "booking_customers"("organization_id");

-- CreateIndex
CREATE UNIQUE INDEX "booking_customers_booking_party" ON "booking_customers"("booking_id", "party_id");

-- CreateIndex
CREATE INDEX "booking_charges_booking_idx" ON "booking_charges"("booking_id");

-- CreateIndex
CREATE INDEX "agreements_booking_idx" ON "agreements"("booking_id");

-- CreateIndex
CREATE UNIQUE INDEX "agreements_org_number" ON "agreements"("organization_id", "agreement_number");

-- CreateIndex
CREATE UNIQUE INDEX "booking_cancellations_booking_id_key" ON "booking_cancellations"("booking_id");

-- CreateIndex
CREATE UNIQUE INDEX "booking_cancellations_journal_entry_id_key" ON "booking_cancellations"("journal_entry_id");

-- CreateIndex
CREATE INDEX "booking_cancellations_org_idx" ON "booking_cancellations"("organization_id");

-- CreateIndex
CREATE UNIQUE INDEX "booking_transfers_journal_entry_id_key" ON "booking_transfers"("journal_entry_id");

-- CreateIndex
CREATE INDEX "booking_transfers_org_idx" ON "booking_transfers"("organization_id");

-- CreateIndex
CREATE INDEX "booking_transfers_unit_idx" ON "booking_transfers"("unit_id");

-- CreateIndex
CREATE INDEX "demand_schedule_org_idx" ON "demand_schedule_items"("organization_id");

-- CreateIndex
CREATE UNIQUE INDEX "demand_schedule_booking_sort" ON "demand_schedule_items"("booking_id", "sort_order");

-- CreateIndex
CREATE INDEX "demand_notes_booking_idx" ON "demand_notes"("booking_id");

-- CreateIndex
CREATE UNIQUE INDEX "demand_notes_org_number" ON "demand_notes"("organization_id", "demand_number");

-- CreateIndex
CREATE INDEX "interest_rules_org_idx" ON "interest_rules"("organization_id");

-- CreateIndex
CREATE UNIQUE INDEX "interest_accruals_journal_entry_id_key" ON "interest_accruals"("journal_entry_id");

-- CreateIndex
CREATE UNIQUE INDEX "interest_accruals_reversal_of_id_key" ON "interest_accruals"("reversal_of_id");

-- CreateIndex
CREATE INDEX "interest_accruals_booking_idx" ON "interest_accruals"("booking_id");

-- CreateIndex
CREATE UNIQUE INDEX "receipts_journal_entry_id_key" ON "receipts"("journal_entry_id");

-- CreateIndex
CREATE UNIQUE INDEX "receipts_client_mutation_id_key" ON "receipts"("client_mutation_id");

-- CreateIndex
CREATE INDEX "receipts_booking_idx" ON "receipts"("booking_id");

-- CreateIndex
CREATE INDEX "receipts_reference_idx" ON "receipts"("instrument_reference");

-- CreateIndex
CREATE UNIQUE INDEX "receipts_org_number" ON "receipts"("organization_id", "receipt_number");

-- CreateIndex
CREATE INDEX "receipt_allocations_receipt_idx" ON "receipt_allocations"("receipt_id");

-- CreateIndex
CREATE INDEX "receipt_allocations_demand_idx" ON "receipt_allocations"("demand_note_id");

-- CreateIndex
CREATE INDEX "customer_statements_booking_idx" ON "customer_statements"("booking_id", "as_of");

-- CreateIndex
CREATE UNIQUE INDEX "progress_updates_client_mutation_id_key" ON "progress_updates"("client_mutation_id");

-- CreateIndex
CREATE INDEX "progress_updates_project_idx" ON "progress_updates"("project_id", "taken_on");

-- CreateIndex
CREATE UNIQUE INDEX "capital_contributions_journal_entry_id_key" ON "capital_contributions"("journal_entry_id");

-- CreateIndex
CREATE INDEX "capital_contributions_project_partner_idx" ON "capital_contributions"("project_id", "partner_party_id");

-- CreateIndex
CREATE UNIQUE INDEX "profit_sharing_agreements_supersedes_id_key" ON "profit_sharing_agreements"("supersedes_id");

-- CreateIndex
CREATE INDEX "profit_sharing_agreements_project_idx" ON "profit_sharing_agreements"("project_id");

-- CreateIndex
CREATE INDEX "profit_sharing_rules_agreement_idx" ON "profit_sharing_rules"("agreement_id");

-- CreateIndex
CREATE INDEX "unit_allocations_unit_idx" ON "unit_allocations"("unit_id");

-- CreateIndex
CREATE INDEX "unit_allocations_partner_idx" ON "unit_allocations"("partner_party_id");

-- CreateIndex
CREATE UNIQUE INDEX "share_computations_journal_entry_id_key" ON "share_computations"("journal_entry_id");

-- CreateIndex
CREATE INDEX "share_computations_project_idx" ON "share_computations"("project_id", "computed_at");

-- CreateIndex
CREATE INDEX "share_ledger_partner_idx" ON "share_ledger_entries"("project_id", "partner_party_id");

-- CreateIndex
CREATE UNIQUE INDEX "share_ledger_org_seq" ON "share_ledger_entries"("organization_id", "sequence");

-- CreateIndex
CREATE INDEX "material_categories_org_idx" ON "material_categories"("organization_id");

-- CreateIndex
CREATE UNIQUE INDEX "materials_org_sku" ON "materials"("organization_id", "sku");

-- CreateIndex
CREATE INDEX "stores_project_idx" ON "stores"("project_id");

-- CreateIndex
CREATE INDEX "indents_project_idx" ON "indents"("project_id");

-- CreateIndex
CREATE UNIQUE INDEX "indents_org_number" ON "indents"("organization_id", "indent_number");

-- CreateIndex
CREATE INDEX "indent_lines_indent_idx" ON "indent_lines"("indent_id");

-- CreateIndex
CREATE INDEX "vendor_quotes_indent_idx" ON "vendor_quotes"("indent_id");

-- CreateIndex
CREATE INDEX "vendor_quote_lines_quote_idx" ON "vendor_quote_lines"("quote_id");

-- CreateIndex
CREATE INDEX "quote_comparisons_indent_idx" ON "quote_comparisons"("indent_id");

-- CreateIndex
CREATE UNIQUE INDEX "purchase_orders_supersedes_id_key" ON "purchase_orders"("supersedes_id");

-- CreateIndex
CREATE INDEX "purchase_orders_project_idx" ON "purchase_orders"("project_id");

-- CreateIndex
CREATE UNIQUE INDEX "purchase_orders_org_number" ON "purchase_orders"("organization_id", "po_number");

-- CreateIndex
CREATE INDEX "purchase_order_lines_po_idx" ON "purchase_order_lines"("purchase_order_id");

-- CreateIndex
CREATE UNIQUE INDEX "goods_receipts_client_mutation_id_key" ON "goods_receipts"("client_mutation_id");

-- CreateIndex
CREATE INDEX "goods_receipts_project_idx" ON "goods_receipts"("project_id");

-- CreateIndex
CREATE UNIQUE INDEX "goods_receipts_org_number" ON "goods_receipts"("organization_id", "grn_number");

-- CreateIndex
CREATE INDEX "goods_receipt_lines_grn_idx" ON "goods_receipt_lines"("goods_receipt_id");

-- CreateIndex
CREATE UNIQUE INDEX "vendor_invoices_journal_entry_id_key" ON "vendor_invoices"("journal_entry_id");

-- CreateIndex
CREATE INDEX "vendor_invoices_fingerprint_idx" ON "vendor_invoices"("organization_id", "fingerprint");

-- CreateIndex
CREATE INDEX "vendor_invoices_project_idx" ON "vendor_invoices"("project_id");

-- CreateIndex
CREATE UNIQUE INDEX "vendor_invoice_org_party_no" ON "vendor_invoices"("organization_id", "vendor_party_id", "invoice_number");

-- CreateIndex
CREATE INDEX "vendor_invoice_lines_invoice_idx" ON "vendor_invoice_lines"("invoice_id");

-- CreateIndex
CREATE UNIQUE INDEX "three_way_matches_vendor_invoice_id_key" ON "three_way_matches"("vendor_invoice_id");

-- CreateIndex
CREATE INDEX "three_way_matches_org_idx" ON "three_way_matches"("organization_id");

-- CreateIndex
CREATE INDEX "three_way_match_lines_match_idx" ON "three_way_match_lines"("match_id");

-- CreateIndex
CREATE INDEX "stock_ledger_store_material_idx" ON "stock_ledger_entries"("store_id", "material_id");

-- CreateIndex
CREATE UNIQUE INDEX "stock_ledger_org_seq" ON "stock_ledger_entries"("organization_id", "sequence");

-- CreateIndex
CREATE UNIQUE INDEX "material_issues_client_mutation_id_key" ON "material_issues"("client_mutation_id");

-- CreateIndex
CREATE INDEX "material_issues_project_idx" ON "material_issues"("project_id", "issued_on");

-- CreateIndex
CREATE INDEX "material_issue_lines_issue_idx" ON "material_issue_lines"("issue_id");

-- CreateIndex
CREATE INDEX "workers_org_idx" ON "workers"("organization_id");

-- CreateIndex
CREATE UNIQUE INDEX "labour_attendances_client_mutation_id_key" ON "labour_attendances"("client_mutation_id");

-- CreateIndex
CREATE INDEX "labour_attendance_project_idx" ON "labour_attendances"("project_id", "work_date");

-- CreateIndex
CREATE UNIQUE INDEX "labour_attendance_worker_date" ON "labour_attendances"("worker_id", "work_date");

-- CreateIndex
CREATE INDEX "work_orders_project_idx" ON "work_orders"("project_id");

-- CreateIndex
CREATE UNIQUE INDEX "work_orders_org_number" ON "work_orders"("organization_id", "wo_number");

-- CreateIndex
CREATE INDEX "work_order_lines_wo_idx" ON "work_order_lines"("work_order_id");

-- CreateIndex
CREATE UNIQUE INDEX "measurement_entries_client_mutation_id_key" ON "measurement_entries"("client_mutation_id");

-- CreateIndex
CREATE INDEX "measurement_entries_project_idx" ON "measurement_entries"("project_id", "measured_on");

-- CreateIndex
CREATE INDEX "measurement_entries_line_idx" ON "measurement_entries"("work_order_line_id");

-- CreateIndex
CREATE UNIQUE INDEX "ra_bills_journal_entry_id_key" ON "ra_bills"("journal_entry_id");

-- CreateIndex
CREATE INDEX "ra_bills_project_idx" ON "ra_bills"("project_id");

-- CreateIndex
CREATE UNIQUE INDEX "ra_bills_org_number" ON "ra_bills"("organization_id", "bill_number");

-- CreateIndex
CREATE INDEX "ra_bill_lines_bill_idx" ON "ra_bill_lines"("ra_bill_id");

-- CreateIndex
CREATE UNIQUE INDEX "retention_entries_journal_entry_id_key" ON "retention_entries"("journal_entry_id");

-- CreateIndex
CREATE INDEX "retention_entries_project_party_idx" ON "retention_entries"("project_id", "contractor_party_id");

-- CreateIndex
CREATE UNIQUE INDEX "contractor_advances_journal_entry_id_key" ON "contractor_advances"("journal_entry_id");

-- CreateIndex
CREATE INDEX "contractor_advances_project_idx" ON "contractor_advances"("project_id");

-- CreateIndex
CREATE UNIQUE INDEX "advance_recoveries_journal_entry_id_key" ON "advance_recoveries"("journal_entry_id");

-- CreateIndex
CREATE INDEX "advance_recoveries_advance_idx" ON "advance_recoveries"("advance_id");

-- CreateIndex
CREATE UNIQUE INDEX "gl_accounts_org_code" ON "gl_accounts"("organization_id", "code");

-- CreateIndex
CREATE UNIQUE INDEX "journal_entries_reversal_of_id_key" ON "journal_entries"("reversal_of_id");

-- CreateIndex
CREATE UNIQUE INDEX "journal_entries_idempotency_key_key" ON "journal_entries"("idempotency_key");

-- CreateIndex
CREATE INDEX "journal_entries_period_idx" ON "journal_entries"("period_id");

-- CreateIndex
CREATE UNIQUE INDEX "journal_entries_org_number" ON "journal_entries"("organization_id", "entry_number");

-- CreateIndex
CREATE UNIQUE INDEX "journal_entries_org_seq" ON "journal_entries"("organization_id", "sequence");

-- CreateIndex
CREATE INDEX "journal_lines_account_idx" ON "journal_lines"("gl_account_id");

-- CreateIndex
CREATE INDEX "journal_lines_project_idx" ON "journal_lines"("project_id");

-- CreateIndex
CREATE INDEX "journal_lines_party_idx" ON "journal_lines"("party_id");

-- CreateIndex
CREATE INDEX "journal_lines_unit_idx" ON "journal_lines"("unit_id");

-- CreateIndex
CREATE UNIQUE INDEX "journal_lines_entry_line" ON "journal_lines"("entry_id", "line_number");

-- CreateIndex
CREATE UNIQUE INDEX "bank_accounts_gl_account_id_key" ON "bank_accounts"("gl_account_id");

-- CreateIndex
CREATE INDEX "bank_accounts_org_idx" ON "bank_accounts"("organization_id");

-- CreateIndex
CREATE INDEX "bank_statement_imports_account_idx" ON "bank_statement_imports"("bank_account_id");

-- CreateIndex
CREATE INDEX "bank_statement_lines_import_idx" ON "bank_statement_lines"("import_id");

-- CreateIndex
CREATE UNIQUE INDEX "bank_statement_lines_fingerprint" ON "bank_statement_lines"("bank_account_id", "fingerprint");

-- CreateIndex
CREATE INDEX "reconciliation_matches_line_idx" ON "reconciliation_matches"("statement_line_id");

-- CreateIndex
CREATE INDEX "reconciliation_matches_journal_idx" ON "reconciliation_matches"("journal_line_id");

-- CreateIndex
CREATE UNIQUE INDEX "budgets_supersedes_id_key" ON "budgets"("supersedes_id");

-- CreateIndex
CREATE INDEX "budgets_project_status_idx" ON "budgets"("project_id", "status");

-- CreateIndex
CREATE INDEX "budget_lines_budget_idx" ON "budget_lines"("budget_id");

-- CreateIndex
CREATE INDEX "loans_project_idx" ON "loans"("project_id");

-- CreateIndex
CREATE UNIQUE INDEX "loan_interest_accruals_journal_entry_id_key" ON "loan_interest_accruals"("journal_entry_id");

-- CreateIndex
CREATE UNIQUE INDEX "loan_interest_accruals_reversal_of_id_key" ON "loan_interest_accruals"("reversal_of_id");

-- CreateIndex
CREATE INDEX "loan_interest_accruals_loan_idx" ON "loan_interest_accruals"("loan_id");

-- CreateIndex
CREATE UNIQUE INDEX "loan_transactions_journal_entry_id_key" ON "loan_transactions"("journal_entry_id");

-- CreateIndex
CREATE INDEX "loan_transactions_loan_idx" ON "loan_transactions"("loan_id", "txn_date");

-- CreateIndex
CREATE UNIQUE INDEX "emi_schedules_supersedes_id_key" ON "emi_schedules"("supersedes_id");

-- CreateIndex
CREATE UNIQUE INDEX "emi_schedules_loan_version" ON "emi_schedules"("loan_id", "version");

-- CreateIndex
CREATE UNIQUE INDEX "emi_lines_schedule_no" ON "emi_schedule_lines"("schedule_id", "installment_number");

-- CreateIndex
CREATE UNIQUE INDEX "payments_journal_entry_id_key" ON "payments"("journal_entry_id");

-- CreateIndex
CREATE UNIQUE INDEX "payments_idempotency_key_key" ON "payments"("idempotency_key");

-- CreateIndex
CREATE INDEX "payments_org_status_idx" ON "payments"("organization_id", "status");

-- CreateIndex
CREATE INDEX "payments_party_idx" ON "payments"("party_id");

-- CreateIndex
CREATE INDEX "payments_date_idx" ON "payments"("payment_date");

-- CreateIndex
CREATE INDEX "payment_allocations_payment_idx" ON "payment_allocations"("payment_id");

-- CreateIndex
CREATE UNIQUE INDEX "payment_source_links_payment_doc" ON "payment_source_links"("payment_id", "document_id");

-- CreateIndex
CREATE UNIQUE INDEX "tally_ledger_maps_org_name" ON "tally_ledger_maps"("organization_id", "tally_ledger_name");

-- CreateIndex
CREATE INDEX "import_batches_org_kind_idx" ON "import_batches"("organization_id", "kind");

-- CreateIndex
CREATE INDEX "documents_entity_idx" ON "documents"("organization_id", "entity_type", "entity_id");

-- CreateIndex
CREATE INDEX "documents_sha_idx" ON "documents"("sha256");

-- CreateIndex
CREATE UNIQUE INDEX "ocr_extractions_document_id_key" ON "ocr_extractions"("document_id");

-- CreateIndex
CREATE UNIQUE INDEX "exception_rules_org_code" ON "exception_rules"("organization_id", "code");

-- CreateIndex
CREATE INDEX "exception_items_org_status_idx" ON "exception_items"("organization_id", "status", "code");

-- CreateIndex
CREATE INDEX "exception_items_entity_idx" ON "exception_items"("entity_type", "entity_id");

-- CreateIndex
CREATE INDEX "notifications_org_status_idx" ON "notifications"("organization_id", "status");

-- CreateIndex
CREATE INDEX "sync_mutations_org_status_idx" ON "sync_mutations"("organization_id", "status");

-- CreateIndex
CREATE UNIQUE INDEX "sync_mutations_device_client" ON "sync_mutations"("device_id", "client_mutation_id");

-- CreateIndex
CREATE INDEX "search_documents_title_idx" ON "search_documents"("organization_id", "title");

-- CreateIndex
CREATE UNIQUE INDEX "search_documents_entity" ON "search_documents"("organization_id", "entity_type", "entity_id");

-- AddForeignKey
ALTER TABLE "auth_accounts" ADD CONSTRAINT "auth_accounts_user_id_fkey" FOREIGN KEY ("user_id") REFERENCES "users"("id") ON DELETE CASCADE ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "auth_sessions" ADD CONSTRAINT "auth_sessions_user_id_fkey" FOREIGN KEY ("user_id") REFERENCES "users"("id") ON DELETE CASCADE ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "memberships" ADD CONSTRAINT "memberships_organization_id_fkey" FOREIGN KEY ("organization_id") REFERENCES "organizations"("id") ON DELETE RESTRICT ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "memberships" ADD CONSTRAINT "memberships_user_id_fkey" FOREIGN KEY ("user_id") REFERENCES "users"("id") ON DELETE RESTRICT ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "memberships" ADD CONSTRAINT "memberships_party_id_fkey" FOREIGN KEY ("party_id") REFERENCES "parties"("id") ON DELETE RESTRICT ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "project_assignments" ADD CONSTRAINT "project_assignments_organization_id_fkey" FOREIGN KEY ("organization_id") REFERENCES "organizations"("id") ON DELETE RESTRICT ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "project_assignments" ADD CONSTRAINT "project_assignments_user_id_fkey" FOREIGN KEY ("user_id") REFERENCES "users"("id") ON DELETE RESTRICT ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "project_assignments" ADD CONSTRAINT "project_assignments_project_id_fkey" FOREIGN KEY ("project_id") REFERENCES "projects"("id") ON DELETE RESTRICT ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "devices" ADD CONSTRAINT "devices_organization_id_fkey" FOREIGN KEY ("organization_id") REFERENCES "organizations"("id") ON DELETE RESTRICT ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "devices" ADD CONSTRAINT "devices_user_id_fkey" FOREIGN KEY ("user_id") REFERENCES "users"("id") ON DELETE RESTRICT ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "audit_events" ADD CONSTRAINT "audit_events_organization_id_fkey" FOREIGN KEY ("organization_id") REFERENCES "organizations"("id") ON DELETE RESTRICT ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "audit_events" ADD CONSTRAINT "audit_events_actor_id_fkey" FOREIGN KEY ("actor_id") REFERENCES "users"("id") ON DELETE RESTRICT ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "chain_heads" ADD CONSTRAINT "chain_heads_organization_id_fkey" FOREIGN KEY ("organization_id") REFERENCES "organizations"("id") ON DELETE RESTRICT ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "approval_policies" ADD CONSTRAINT "approval_policies_organization_id_fkey" FOREIGN KEY ("organization_id") REFERENCES "organizations"("id") ON DELETE RESTRICT ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "approval_requests" ADD CONSTRAINT "approval_requests_organization_id_fkey" FOREIGN KEY ("organization_id") REFERENCES "organizations"("id") ON DELETE RESTRICT ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "approval_requests" ADD CONSTRAINT "approval_requests_requested_by_id_fkey" FOREIGN KEY ("requested_by_id") REFERENCES "users"("id") ON DELETE RESTRICT ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "approval_actions" ADD CONSTRAINT "approval_actions_organization_id_fkey" FOREIGN KEY ("organization_id") REFERENCES "organizations"("id") ON DELETE RESTRICT ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "approval_actions" ADD CONSTRAINT "approval_actions_request_id_fkey" FOREIGN KEY ("request_id") REFERENCES "approval_requests"("id") ON DELETE RESTRICT ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "approval_actions" ADD CONSTRAINT "approval_actions_actor_id_fkey" FOREIGN KEY ("actor_id") REFERENCES "users"("id") ON DELETE RESTRICT ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "fiscal_years" ADD CONSTRAINT "fiscal_years_organization_id_fkey" FOREIGN KEY ("organization_id") REFERENCES "organizations"("id") ON DELETE RESTRICT ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "accounting_periods" ADD CONSTRAINT "accounting_periods_organization_id_fkey" FOREIGN KEY ("organization_id") REFERENCES "organizations"("id") ON DELETE RESTRICT ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "accounting_periods" ADD CONSTRAINT "accounting_periods_fiscal_year_id_fkey" FOREIGN KEY ("fiscal_year_id") REFERENCES "fiscal_years"("id") ON DELETE RESTRICT ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "accounting_periods" ADD CONSTRAINT "accounting_periods_locked_by_id_fkey" FOREIGN KEY ("locked_by_id") REFERENCES "users"("id") ON DELETE RESTRICT ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "period_lock_events" ADD CONSTRAINT "period_lock_events_organization_id_fkey" FOREIGN KEY ("organization_id") REFERENCES "organizations"("id") ON DELETE RESTRICT ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "period_lock_events" ADD CONSTRAINT "period_lock_events_period_id_fkey" FOREIGN KEY ("period_id") REFERENCES "accounting_periods"("id") ON DELETE RESTRICT ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "period_lock_events" ADD CONSTRAINT "period_lock_events_actor_id_fkey" FOREIGN KEY ("actor_id") REFERENCES "users"("id") ON DELETE RESTRICT ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "period_lock_events" ADD CONSTRAINT "period_lock_events_approval_request_id_fkey" FOREIGN KEY ("approval_request_id") REFERENCES "approval_requests"("id") ON DELETE RESTRICT ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "document_sequences" ADD CONSTRAINT "document_sequences_organization_id_fkey" FOREIGN KEY ("organization_id") REFERENCES "organizations"("id") ON DELETE RESTRICT ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "document_sequences" ADD CONSTRAINT "document_sequences_fiscal_year_id_fkey" FOREIGN KEY ("fiscal_year_id") REFERENCES "fiscal_years"("id") ON DELETE RESTRICT ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "parties" ADD CONSTRAINT "parties_organization_id_fkey" FOREIGN KEY ("organization_id") REFERENCES "organizations"("id") ON DELETE RESTRICT ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "parties" ADD CONSTRAINT "parties_related_to_party_id_fkey" FOREIGN KEY ("related_to_party_id") REFERENCES "parties"("id") ON DELETE RESTRICT ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "party_addresses" ADD CONSTRAINT "party_addresses_organization_id_fkey" FOREIGN KEY ("organization_id") REFERENCES "organizations"("id") ON DELETE RESTRICT ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "party_addresses" ADD CONSTRAINT "party_addresses_party_id_fkey" FOREIGN KEY ("party_id") REFERENCES "parties"("id") ON DELETE RESTRICT ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "party_bank_accounts" ADD CONSTRAINT "party_bank_accounts_organization_id_fkey" FOREIGN KEY ("organization_id") REFERENCES "organizations"("id") ON DELETE RESTRICT ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "party_bank_accounts" ADD CONSTRAINT "party_bank_accounts_party_id_fkey" FOREIGN KEY ("party_id") REFERENCES "parties"("id") ON DELETE RESTRICT ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "party_contacts" ADD CONSTRAINT "party_contacts_organization_id_fkey" FOREIGN KEY ("organization_id") REFERENCES "organizations"("id") ON DELETE RESTRICT ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "party_contacts" ADD CONSTRAINT "party_contacts_party_id_fkey" FOREIGN KEY ("party_id") REFERENCES "parties"("id") ON DELETE RESTRICT ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "vendor_profiles" ADD CONSTRAINT "vendor_profiles_organization_id_fkey" FOREIGN KEY ("organization_id") REFERENCES "organizations"("id") ON DELETE RESTRICT ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "vendor_profiles" ADD CONSTRAINT "vendor_profiles_party_id_fkey" FOREIGN KEY ("party_id") REFERENCES "parties"("id") ON DELETE RESTRICT ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "vendor_profiles" ADD CONSTRAINT "vendor_profiles_tds_section_id_fkey" FOREIGN KEY ("tds_section_id") REFERENCES "tds_sections"("id") ON DELETE RESTRICT ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "contractor_profiles" ADD CONSTRAINT "contractor_profiles_organization_id_fkey" FOREIGN KEY ("organization_id") REFERENCES "organizations"("id") ON DELETE RESTRICT ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "contractor_profiles" ADD CONSTRAINT "contractor_profiles_party_id_fkey" FOREIGN KEY ("party_id") REFERENCES "parties"("id") ON DELETE RESTRICT ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "projects" ADD CONSTRAINT "projects_organization_id_fkey" FOREIGN KEY ("organization_id") REFERENCES "organizations"("id") ON DELETE RESTRICT ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "project_phases" ADD CONSTRAINT "project_phases_organization_id_fkey" FOREIGN KEY ("organization_id") REFERENCES "organizations"("id") ON DELETE RESTRICT ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "project_phases" ADD CONSTRAINT "project_phases_project_id_fkey" FOREIGN KEY ("project_id") REFERENCES "projects"("id") ON DELETE RESTRICT ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "towers" ADD CONSTRAINT "towers_organization_id_fkey" FOREIGN KEY ("organization_id") REFERENCES "organizations"("id") ON DELETE RESTRICT ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "towers" ADD CONSTRAINT "towers_project_id_fkey" FOREIGN KEY ("project_id") REFERENCES "projects"("id") ON DELETE RESTRICT ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "towers" ADD CONSTRAINT "towers_phase_id_fkey" FOREIGN KEY ("phase_id") REFERENCES "project_phases"("id") ON DELETE RESTRICT ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "floors" ADD CONSTRAINT "floors_organization_id_fkey" FOREIGN KEY ("organization_id") REFERENCES "organizations"("id") ON DELETE RESTRICT ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "floors" ADD CONSTRAINT "floors_project_id_fkey" FOREIGN KEY ("project_id") REFERENCES "projects"("id") ON DELETE RESTRICT ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "floors" ADD CONSTRAINT "floors_tower_id_fkey" FOREIGN KEY ("tower_id") REFERENCES "towers"("id") ON DELETE RESTRICT ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "units" ADD CONSTRAINT "units_organization_id_fkey" FOREIGN KEY ("organization_id") REFERENCES "organizations"("id") ON DELETE RESTRICT ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "units" ADD CONSTRAINT "units_project_id_fkey" FOREIGN KEY ("project_id") REFERENCES "projects"("id") ON DELETE RESTRICT ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "units" ADD CONSTRAINT "units_tower_id_fkey" FOREIGN KEY ("tower_id") REFERENCES "towers"("id") ON DELETE RESTRICT ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "units" ADD CONSTRAINT "units_floor_id_fkey" FOREIGN KEY ("floor_id") REFERENCES "floors"("id") ON DELETE RESTRICT ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "unit_area_revisions" ADD CONSTRAINT "unit_area_revisions_organization_id_fkey" FOREIGN KEY ("organization_id") REFERENCES "organizations"("id") ON DELETE RESTRICT ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "unit_area_revisions" ADD CONSTRAINT "unit_area_revisions_project_id_fkey" FOREIGN KEY ("project_id") REFERENCES "projects"("id") ON DELETE RESTRICT ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "unit_area_revisions" ADD CONSTRAINT "unit_area_revisions_unit_id_fkey" FOREIGN KEY ("unit_id") REFERENCES "units"("id") ON DELETE RESTRICT ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "unit_area_revisions" ADD CONSTRAINT "unit_area_revisions_recorded_by_id_fkey" FOREIGN KEY ("recorded_by_id") REFERENCES "users"("id") ON DELETE RESTRICT ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "cost_centres" ADD CONSTRAINT "cost_centres_organization_id_fkey" FOREIGN KEY ("organization_id") REFERENCES "organizations"("id") ON DELETE RESTRICT ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "cost_centres" ADD CONSTRAINT "cost_centres_project_id_fkey" FOREIGN KEY ("project_id") REFERENCES "projects"("id") ON DELETE RESTRICT ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "cost_centres" ADD CONSTRAINT "cost_centres_parent_id_fkey" FOREIGN KEY ("parent_id") REFERENCES "cost_centres"("id") ON DELETE RESTRICT ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "boq_items" ADD CONSTRAINT "boq_items_organization_id_fkey" FOREIGN KEY ("organization_id") REFERENCES "organizations"("id") ON DELETE RESTRICT ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "boq_items" ADD CONSTRAINT "boq_items_project_id_fkey" FOREIGN KEY ("project_id") REFERENCES "projects"("id") ON DELETE RESTRICT ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "boq_items" ADD CONSTRAINT "boq_items_cost_centre_id_fkey" FOREIGN KEY ("cost_centre_id") REFERENCES "cost_centres"("id") ON DELETE RESTRICT ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "boq_items" ADD CONSTRAINT "boq_items_material_id_fkey" FOREIGN KEY ("material_id") REFERENCES "materials"("id") ON DELETE RESTRICT ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "leads" ADD CONSTRAINT "leads_organization_id_fkey" FOREIGN KEY ("organization_id") REFERENCES "organizations"("id") ON DELETE RESTRICT ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "leads" ADD CONSTRAINT "leads_project_id_fkey" FOREIGN KEY ("project_id") REFERENCES "projects"("id") ON DELETE RESTRICT ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "leads" ADD CONSTRAINT "leads_assigned_to_id_fkey" FOREIGN KEY ("assigned_to_id") REFERENCES "users"("id") ON DELETE RESTRICT ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "lead_followups" ADD CONSTRAINT "lead_followups_organization_id_fkey" FOREIGN KEY ("organization_id") REFERENCES "organizations"("id") ON DELETE RESTRICT ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "lead_followups" ADD CONSTRAINT "lead_followups_lead_id_fkey" FOREIGN KEY ("lead_id") REFERENCES "leads"("id") ON DELETE RESTRICT ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "lead_followups" ADD CONSTRAINT "lead_followups_assigned_to_id_fkey" FOREIGN KEY ("assigned_to_id") REFERENCES "users"("id") ON DELETE RESTRICT ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "site_visits" ADD CONSTRAINT "site_visits_organization_id_fkey" FOREIGN KEY ("organization_id") REFERENCES "organizations"("id") ON DELETE RESTRICT ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "site_visits" ADD CONSTRAINT "site_visits_lead_id_fkey" FOREIGN KEY ("lead_id") REFERENCES "leads"("id") ON DELETE RESTRICT ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "site_visits" ADD CONSTRAINT "site_visits_project_id_fkey" FOREIGN KEY ("project_id") REFERENCES "projects"("id") ON DELETE RESTRICT ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "site_visits" ADD CONSTRAINT "site_visits_unit_id_fkey" FOREIGN KEY ("unit_id") REFERENCES "units"("id") ON DELETE RESTRICT ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "site_visits" ADD CONSTRAINT "site_visits_conducted_by_id_fkey" FOREIGN KEY ("conducted_by_id") REFERENCES "users"("id") ON DELETE RESTRICT ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "lead_activities" ADD CONSTRAINT "lead_activities_organization_id_fkey" FOREIGN KEY ("organization_id") REFERENCES "organizations"("id") ON DELETE RESTRICT ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "lead_activities" ADD CONSTRAINT "lead_activities_lead_id_fkey" FOREIGN KEY ("lead_id") REFERENCES "leads"("id") ON DELETE RESTRICT ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "lead_activities" ADD CONSTRAINT "lead_activities_actor_id_fkey" FOREIGN KEY ("actor_id") REFERENCES "users"("id") ON DELETE RESTRICT ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "bookings" ADD CONSTRAINT "bookings_organization_id_fkey" FOREIGN KEY ("organization_id") REFERENCES "organizations"("id") ON DELETE RESTRICT ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "bookings" ADD CONSTRAINT "bookings_project_id_fkey" FOREIGN KEY ("project_id") REFERENCES "projects"("id") ON DELETE RESTRICT ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "bookings" ADD CONSTRAINT "bookings_unit_id_fkey" FOREIGN KEY ("unit_id") REFERENCES "units"("id") ON DELETE RESTRICT ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "bookings" ADD CONSTRAINT "bookings_lead_id_fkey" FOREIGN KEY ("lead_id") REFERENCES "leads"("id") ON DELETE RESTRICT ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "bookings" ADD CONSTRAINT "bookings_sales_owner_id_fkey" FOREIGN KEY ("sales_owner_id") REFERENCES "users"("id") ON DELETE RESTRICT ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "bookings" ADD CONSTRAINT "bookings_gst_rate_id_fkey" FOREIGN KEY ("gst_rate_id") REFERENCES "gst_rates"("id") ON DELETE RESTRICT ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "booking_customers" ADD CONSTRAINT "booking_customers_organization_id_fkey" FOREIGN KEY ("organization_id") REFERENCES "organizations"("id") ON DELETE RESTRICT ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "booking_customers" ADD CONSTRAINT "booking_customers_booking_id_fkey" FOREIGN KEY ("booking_id") REFERENCES "bookings"("id") ON DELETE RESTRICT ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "booking_customers" ADD CONSTRAINT "booking_customers_party_id_fkey" FOREIGN KEY ("party_id") REFERENCES "parties"("id") ON DELETE RESTRICT ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "booking_charges" ADD CONSTRAINT "booking_charges_organization_id_fkey" FOREIGN KEY ("organization_id") REFERENCES "organizations"("id") ON DELETE RESTRICT ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "booking_charges" ADD CONSTRAINT "booking_charges_booking_id_fkey" FOREIGN KEY ("booking_id") REFERENCES "bookings"("id") ON DELETE RESTRICT ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "agreements" ADD CONSTRAINT "agreements_organization_id_fkey" FOREIGN KEY ("organization_id") REFERENCES "organizations"("id") ON DELETE RESTRICT ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "agreements" ADD CONSTRAINT "agreements_project_id_fkey" FOREIGN KEY ("project_id") REFERENCES "projects"("id") ON DELETE RESTRICT ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "agreements" ADD CONSTRAINT "agreements_booking_id_fkey" FOREIGN KEY ("booking_id") REFERENCES "bookings"("id") ON DELETE RESTRICT ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "booking_cancellations" ADD CONSTRAINT "booking_cancellations_organization_id_fkey" FOREIGN KEY ("organization_id") REFERENCES "organizations"("id") ON DELETE RESTRICT ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "booking_cancellations" ADD CONSTRAINT "booking_cancellations_project_id_fkey" FOREIGN KEY ("project_id") REFERENCES "projects"("id") ON DELETE RESTRICT ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "booking_cancellations" ADD CONSTRAINT "booking_cancellations_booking_id_fkey" FOREIGN KEY ("booking_id") REFERENCES "bookings"("id") ON DELETE RESTRICT ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "booking_cancellations" ADD CONSTRAINT "booking_cancellations_approval_request_id_fkey" FOREIGN KEY ("approval_request_id") REFERENCES "approval_requests"("id") ON DELETE RESTRICT ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "booking_cancellations" ADD CONSTRAINT "booking_cancellations_journal_entry_id_fkey" FOREIGN KEY ("journal_entry_id") REFERENCES "journal_entries"("id") ON DELETE RESTRICT ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "booking_transfers" ADD CONSTRAINT "booking_transfers_organization_id_fkey" FOREIGN KEY ("organization_id") REFERENCES "organizations"("id") ON DELETE RESTRICT ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "booking_transfers" ADD CONSTRAINT "booking_transfers_project_id_fkey" FOREIGN KEY ("project_id") REFERENCES "projects"("id") ON DELETE RESTRICT ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "booking_transfers" ADD CONSTRAINT "booking_transfers_unit_id_fkey" FOREIGN KEY ("unit_id") REFERENCES "units"("id") ON DELETE RESTRICT ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "booking_transfers" ADD CONSTRAINT "booking_transfers_from_booking_id_fkey" FOREIGN KEY ("from_booking_id") REFERENCES "bookings"("id") ON DELETE RESTRICT ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "booking_transfers" ADD CONSTRAINT "booking_transfers_to_booking_id_fkey" FOREIGN KEY ("to_booking_id") REFERENCES "bookings"("id") ON DELETE RESTRICT ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "booking_transfers" ADD CONSTRAINT "booking_transfers_from_party_id_fkey" FOREIGN KEY ("from_party_id") REFERENCES "parties"("id") ON DELETE RESTRICT ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "booking_transfers" ADD CONSTRAINT "booking_transfers_to_party_id_fkey" FOREIGN KEY ("to_party_id") REFERENCES "parties"("id") ON DELETE RESTRICT ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "booking_transfers" ADD CONSTRAINT "booking_transfers_approval_request_id_fkey" FOREIGN KEY ("approval_request_id") REFERENCES "approval_requests"("id") ON DELETE RESTRICT ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "booking_transfers" ADD CONSTRAINT "booking_transfers_journal_entry_id_fkey" FOREIGN KEY ("journal_entry_id") REFERENCES "journal_entries"("id") ON DELETE RESTRICT ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "demand_schedule_items" ADD CONSTRAINT "demand_schedule_items_organization_id_fkey" FOREIGN KEY ("organization_id") REFERENCES "organizations"("id") ON DELETE RESTRICT ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "demand_schedule_items" ADD CONSTRAINT "demand_schedule_items_project_id_fkey" FOREIGN KEY ("project_id") REFERENCES "projects"("id") ON DELETE RESTRICT ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "demand_schedule_items" ADD CONSTRAINT "demand_schedule_items_booking_id_fkey" FOREIGN KEY ("booking_id") REFERENCES "bookings"("id") ON DELETE RESTRICT ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "demand_notes" ADD CONSTRAINT "demand_notes_organization_id_fkey" FOREIGN KEY ("organization_id") REFERENCES "organizations"("id") ON DELETE RESTRICT ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "demand_notes" ADD CONSTRAINT "demand_notes_project_id_fkey" FOREIGN KEY ("project_id") REFERENCES "projects"("id") ON DELETE RESTRICT ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "demand_notes" ADD CONSTRAINT "demand_notes_booking_id_fkey" FOREIGN KEY ("booking_id") REFERENCES "bookings"("id") ON DELETE RESTRICT ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "demand_notes" ADD CONSTRAINT "demand_notes_schedule_item_id_fkey" FOREIGN KEY ("schedule_item_id") REFERENCES "demand_schedule_items"("id") ON DELETE RESTRICT ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "demand_notes" ADD CONSTRAINT "demand_notes_gst_rate_id_fkey" FOREIGN KEY ("gst_rate_id") REFERENCES "gst_rates"("id") ON DELETE RESTRICT ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "interest_rules" ADD CONSTRAINT "interest_rules_organization_id_fkey" FOREIGN KEY ("organization_id") REFERENCES "organizations"("id") ON DELETE RESTRICT ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "interest_rules" ADD CONSTRAINT "interest_rules_project_id_fkey" FOREIGN KEY ("project_id") REFERENCES "projects"("id") ON DELETE RESTRICT ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "interest_accruals" ADD CONSTRAINT "interest_accruals_organization_id_fkey" FOREIGN KEY ("organization_id") REFERENCES "organizations"("id") ON DELETE RESTRICT ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "interest_accruals" ADD CONSTRAINT "interest_accruals_project_id_fkey" FOREIGN KEY ("project_id") REFERENCES "projects"("id") ON DELETE RESTRICT ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "interest_accruals" ADD CONSTRAINT "interest_accruals_booking_id_fkey" FOREIGN KEY ("booking_id") REFERENCES "bookings"("id") ON DELETE RESTRICT ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "interest_accruals" ADD CONSTRAINT "interest_accruals_demand_note_id_fkey" FOREIGN KEY ("demand_note_id") REFERENCES "demand_notes"("id") ON DELETE RESTRICT ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "interest_accruals" ADD CONSTRAINT "interest_accruals_rule_id_fkey" FOREIGN KEY ("rule_id") REFERENCES "interest_rules"("id") ON DELETE RESTRICT ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "interest_accruals" ADD CONSTRAINT "interest_accruals_journal_entry_id_fkey" FOREIGN KEY ("journal_entry_id") REFERENCES "journal_entries"("id") ON DELETE RESTRICT ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "interest_accruals" ADD CONSTRAINT "interest_accruals_reversal_of_id_fkey" FOREIGN KEY ("reversal_of_id") REFERENCES "interest_accruals"("id") ON DELETE RESTRICT ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "interest_accruals" ADD CONSTRAINT "interest_accruals_recorded_by_id_fkey" FOREIGN KEY ("recorded_by_id") REFERENCES "users"("id") ON DELETE RESTRICT ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "receipts" ADD CONSTRAINT "receipts_organization_id_fkey" FOREIGN KEY ("organization_id") REFERENCES "organizations"("id") ON DELETE RESTRICT ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "receipts" ADD CONSTRAINT "receipts_project_id_fkey" FOREIGN KEY ("project_id") REFERENCES "projects"("id") ON DELETE RESTRICT ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "receipts" ADD CONSTRAINT "receipts_booking_id_fkey" FOREIGN KEY ("booking_id") REFERENCES "bookings"("id") ON DELETE RESTRICT ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "receipts" ADD CONSTRAINT "receipts_payer_party_id_fkey" FOREIGN KEY ("payer_party_id") REFERENCES "parties"("id") ON DELETE RESTRICT ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "receipts" ADD CONSTRAINT "receipts_bank_account_id_fkey" FOREIGN KEY ("bank_account_id") REFERENCES "bank_accounts"("id") ON DELETE RESTRICT ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "receipts" ADD CONSTRAINT "receipts_recorded_by_id_fkey" FOREIGN KEY ("recorded_by_id") REFERENCES "users"("id") ON DELETE RESTRICT ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "receipts" ADD CONSTRAINT "receipts_journal_entry_id_fkey" FOREIGN KEY ("journal_entry_id") REFERENCES "journal_entries"("id") ON DELETE RESTRICT ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "receipt_allocations" ADD CONSTRAINT "receipt_allocations_organization_id_fkey" FOREIGN KEY ("organization_id") REFERENCES "organizations"("id") ON DELETE RESTRICT ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "receipt_allocations" ADD CONSTRAINT "receipt_allocations_receipt_id_fkey" FOREIGN KEY ("receipt_id") REFERENCES "receipts"("id") ON DELETE RESTRICT ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "receipt_allocations" ADD CONSTRAINT "receipt_allocations_demand_note_id_fkey" FOREIGN KEY ("demand_note_id") REFERENCES "demand_notes"("id") ON DELETE RESTRICT ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "customer_statements" ADD CONSTRAINT "customer_statements_organization_id_fkey" FOREIGN KEY ("organization_id") REFERENCES "organizations"("id") ON DELETE RESTRICT ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "customer_statements" ADD CONSTRAINT "customer_statements_project_id_fkey" FOREIGN KEY ("project_id") REFERENCES "projects"("id") ON DELETE RESTRICT ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "customer_statements" ADD CONSTRAINT "customer_statements_booking_id_fkey" FOREIGN KEY ("booking_id") REFERENCES "bookings"("id") ON DELETE RESTRICT ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "customer_statements" ADD CONSTRAINT "customer_statements_issued_by_id_fkey" FOREIGN KEY ("issued_by_id") REFERENCES "users"("id") ON DELETE RESTRICT ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "progress_updates" ADD CONSTRAINT "progress_updates_organization_id_fkey" FOREIGN KEY ("organization_id") REFERENCES "organizations"("id") ON DELETE RESTRICT ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "progress_updates" ADD CONSTRAINT "progress_updates_project_id_fkey" FOREIGN KEY ("project_id") REFERENCES "projects"("id") ON DELETE RESTRICT ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "progress_updates" ADD CONSTRAINT "progress_updates_phase_id_fkey" FOREIGN KEY ("phase_id") REFERENCES "project_phases"("id") ON DELETE RESTRICT ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "progress_updates" ADD CONSTRAINT "progress_updates_tower_id_fkey" FOREIGN KEY ("tower_id") REFERENCES "towers"("id") ON DELETE RESTRICT ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "progress_updates" ADD CONSTRAINT "progress_updates_floor_id_fkey" FOREIGN KEY ("floor_id") REFERENCES "floors"("id") ON DELETE RESTRICT ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "progress_updates" ADD CONSTRAINT "progress_updates_unit_id_fkey" FOREIGN KEY ("unit_id") REFERENCES "units"("id") ON DELETE RESTRICT ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "progress_updates" ADD CONSTRAINT "progress_updates_recorded_by_id_fkey" FOREIGN KEY ("recorded_by_id") REFERENCES "users"("id") ON DELETE RESTRICT ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "capital_contributions" ADD CONSTRAINT "capital_contributions_organization_id_fkey" FOREIGN KEY ("organization_id") REFERENCES "organizations"("id") ON DELETE RESTRICT ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "capital_contributions" ADD CONSTRAINT "capital_contributions_project_id_fkey" FOREIGN KEY ("project_id") REFERENCES "projects"("id") ON DELETE RESTRICT ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "capital_contributions" ADD CONSTRAINT "capital_contributions_partner_party_id_fkey" FOREIGN KEY ("partner_party_id") REFERENCES "parties"("id") ON DELETE RESTRICT ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "capital_contributions" ADD CONSTRAINT "capital_contributions_journal_entry_id_fkey" FOREIGN KEY ("journal_entry_id") REFERENCES "journal_entries"("id") ON DELETE RESTRICT ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "profit_sharing_agreements" ADD CONSTRAINT "profit_sharing_agreements_organization_id_fkey" FOREIGN KEY ("organization_id") REFERENCES "organizations"("id") ON DELETE RESTRICT ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "profit_sharing_agreements" ADD CONSTRAINT "profit_sharing_agreements_project_id_fkey" FOREIGN KEY ("project_id") REFERENCES "projects"("id") ON DELETE RESTRICT ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "profit_sharing_agreements" ADD CONSTRAINT "profit_sharing_agreements_supersedes_id_fkey" FOREIGN KEY ("supersedes_id") REFERENCES "profit_sharing_agreements"("id") ON DELETE RESTRICT ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "profit_sharing_rules" ADD CONSTRAINT "profit_sharing_rules_organization_id_fkey" FOREIGN KEY ("organization_id") REFERENCES "organizations"("id") ON DELETE RESTRICT ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "profit_sharing_rules" ADD CONSTRAINT "profit_sharing_rules_project_id_fkey" FOREIGN KEY ("project_id") REFERENCES "projects"("id") ON DELETE RESTRICT ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "profit_sharing_rules" ADD CONSTRAINT "profit_sharing_rules_agreement_id_fkey" FOREIGN KEY ("agreement_id") REFERENCES "profit_sharing_agreements"("id") ON DELETE RESTRICT ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "profit_sharing_rules" ADD CONSTRAINT "profit_sharing_rules_partner_party_id_fkey" FOREIGN KEY ("partner_party_id") REFERENCES "parties"("id") ON DELETE RESTRICT ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "unit_allocations" ADD CONSTRAINT "unit_allocations_organization_id_fkey" FOREIGN KEY ("organization_id") REFERENCES "organizations"("id") ON DELETE RESTRICT ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "unit_allocations" ADD CONSTRAINT "unit_allocations_project_id_fkey" FOREIGN KEY ("project_id") REFERENCES "projects"("id") ON DELETE RESTRICT ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "unit_allocations" ADD CONSTRAINT "unit_allocations_unit_id_fkey" FOREIGN KEY ("unit_id") REFERENCES "units"("id") ON DELETE RESTRICT ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "unit_allocations" ADD CONSTRAINT "unit_allocations_partner_party_id_fkey" FOREIGN KEY ("partner_party_id") REFERENCES "parties"("id") ON DELETE RESTRICT ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "share_computations" ADD CONSTRAINT "share_computations_organization_id_fkey" FOREIGN KEY ("organization_id") REFERENCES "organizations"("id") ON DELETE RESTRICT ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "share_computations" ADD CONSTRAINT "share_computations_project_id_fkey" FOREIGN KEY ("project_id") REFERENCES "projects"("id") ON DELETE RESTRICT ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "share_computations" ADD CONSTRAINT "share_computations_agreement_id_fkey" FOREIGN KEY ("agreement_id") REFERENCES "profit_sharing_agreements"("id") ON DELETE RESTRICT ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "share_computations" ADD CONSTRAINT "share_computations_computed_by_id_fkey" FOREIGN KEY ("computed_by_id") REFERENCES "users"("id") ON DELETE RESTRICT ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "share_computations" ADD CONSTRAINT "share_computations_journal_entry_id_fkey" FOREIGN KEY ("journal_entry_id") REFERENCES "journal_entries"("id") ON DELETE RESTRICT ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "share_ledger_entries" ADD CONSTRAINT "share_ledger_entries_organization_id_fkey" FOREIGN KEY ("organization_id") REFERENCES "organizations"("id") ON DELETE RESTRICT ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "share_ledger_entries" ADD CONSTRAINT "share_ledger_entries_project_id_fkey" FOREIGN KEY ("project_id") REFERENCES "projects"("id") ON DELETE RESTRICT ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "share_ledger_entries" ADD CONSTRAINT "share_ledger_entries_partner_party_id_fkey" FOREIGN KEY ("partner_party_id") REFERENCES "parties"("id") ON DELETE RESTRICT ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "share_ledger_entries" ADD CONSTRAINT "share_ledger_entries_computation_id_fkey" FOREIGN KEY ("computation_id") REFERENCES "share_computations"("id") ON DELETE RESTRICT ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "material_categories" ADD CONSTRAINT "material_categories_organization_id_fkey" FOREIGN KEY ("organization_id") REFERENCES "organizations"("id") ON DELETE RESTRICT ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "material_categories" ADD CONSTRAINT "material_categories_parent_id_fkey" FOREIGN KEY ("parent_id") REFERENCES "material_categories"("id") ON DELETE RESTRICT ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "materials" ADD CONSTRAINT "materials_organization_id_fkey" FOREIGN KEY ("organization_id") REFERENCES "organizations"("id") ON DELETE RESTRICT ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "materials" ADD CONSTRAINT "materials_category_id_fkey" FOREIGN KEY ("category_id") REFERENCES "material_categories"("id") ON DELETE RESTRICT ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "materials" ADD CONSTRAINT "materials_gst_rate_id_fkey" FOREIGN KEY ("gst_rate_id") REFERENCES "gst_rates"("id") ON DELETE RESTRICT ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "stores" ADD CONSTRAINT "stores_organization_id_fkey" FOREIGN KEY ("organization_id") REFERENCES "organizations"("id") ON DELETE RESTRICT ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "stores" ADD CONSTRAINT "stores_project_id_fkey" FOREIGN KEY ("project_id") REFERENCES "projects"("id") ON DELETE RESTRICT ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "indents" ADD CONSTRAINT "indents_organization_id_fkey" FOREIGN KEY ("organization_id") REFERENCES "organizations"("id") ON DELETE RESTRICT ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "indents" ADD CONSTRAINT "indents_project_id_fkey" FOREIGN KEY ("project_id") REFERENCES "projects"("id") ON DELETE RESTRICT ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "indents" ADD CONSTRAINT "indents_store_id_fkey" FOREIGN KEY ("store_id") REFERENCES "stores"("id") ON DELETE RESTRICT ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "indents" ADD CONSTRAINT "indents_requested_by_id_fkey" FOREIGN KEY ("requested_by_id") REFERENCES "users"("id") ON DELETE RESTRICT ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "indent_lines" ADD CONSTRAINT "indent_lines_organization_id_fkey" FOREIGN KEY ("organization_id") REFERENCES "organizations"("id") ON DELETE RESTRICT ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "indent_lines" ADD CONSTRAINT "indent_lines_indent_id_fkey" FOREIGN KEY ("indent_id") REFERENCES "indents"("id") ON DELETE RESTRICT ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "indent_lines" ADD CONSTRAINT "indent_lines_material_id_fkey" FOREIGN KEY ("material_id") REFERENCES "materials"("id") ON DELETE RESTRICT ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "indent_lines" ADD CONSTRAINT "indent_lines_boq_item_id_fkey" FOREIGN KEY ("boq_item_id") REFERENCES "boq_items"("id") ON DELETE RESTRICT ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "vendor_quotes" ADD CONSTRAINT "vendor_quotes_organization_id_fkey" FOREIGN KEY ("organization_id") REFERENCES "organizations"("id") ON DELETE RESTRICT ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "vendor_quotes" ADD CONSTRAINT "vendor_quotes_indent_id_fkey" FOREIGN KEY ("indent_id") REFERENCES "indents"("id") ON DELETE RESTRICT ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "vendor_quotes" ADD CONSTRAINT "vendor_quotes_vendor_party_id_fkey" FOREIGN KEY ("vendor_party_id") REFERENCES "parties"("id") ON DELETE RESTRICT ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "vendor_quote_lines" ADD CONSTRAINT "vendor_quote_lines_organization_id_fkey" FOREIGN KEY ("organization_id") REFERENCES "organizations"("id") ON DELETE RESTRICT ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "vendor_quote_lines" ADD CONSTRAINT "vendor_quote_lines_quote_id_fkey" FOREIGN KEY ("quote_id") REFERENCES "vendor_quotes"("id") ON DELETE RESTRICT ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "vendor_quote_lines" ADD CONSTRAINT "vendor_quote_lines_indent_line_id_fkey" FOREIGN KEY ("indent_line_id") REFERENCES "indent_lines"("id") ON DELETE RESTRICT ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "vendor_quote_lines" ADD CONSTRAINT "vendor_quote_lines_gst_rate_id_fkey" FOREIGN KEY ("gst_rate_id") REFERENCES "gst_rates"("id") ON DELETE RESTRICT ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "quote_comparisons" ADD CONSTRAINT "quote_comparisons_organization_id_fkey" FOREIGN KEY ("organization_id") REFERENCES "organizations"("id") ON DELETE RESTRICT ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "quote_comparisons" ADD CONSTRAINT "quote_comparisons_indent_id_fkey" FOREIGN KEY ("indent_id") REFERENCES "indents"("id") ON DELETE RESTRICT ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "quote_comparisons" ADD CONSTRAINT "quote_comparisons_compared_by_id_fkey" FOREIGN KEY ("compared_by_id") REFERENCES "users"("id") ON DELETE RESTRICT ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "quote_comparisons" ADD CONSTRAINT "quote_comparisons_selected_quote_id_fkey" FOREIGN KEY ("selected_quote_id") REFERENCES "vendor_quotes"("id") ON DELETE RESTRICT ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "purchase_orders" ADD CONSTRAINT "purchase_orders_organization_id_fkey" FOREIGN KEY ("organization_id") REFERENCES "organizations"("id") ON DELETE RESTRICT ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "purchase_orders" ADD CONSTRAINT "purchase_orders_project_id_fkey" FOREIGN KEY ("project_id") REFERENCES "projects"("id") ON DELETE RESTRICT ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "purchase_orders" ADD CONSTRAINT "purchase_orders_vendor_party_id_fkey" FOREIGN KEY ("vendor_party_id") REFERENCES "parties"("id") ON DELETE RESTRICT ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "purchase_orders" ADD CONSTRAINT "purchase_orders_quote_id_fkey" FOREIGN KEY ("quote_id") REFERENCES "vendor_quotes"("id") ON DELETE RESTRICT ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "purchase_orders" ADD CONSTRAINT "purchase_orders_indent_id_fkey" FOREIGN KEY ("indent_id") REFERENCES "indents"("id") ON DELETE RESTRICT ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "purchase_orders" ADD CONSTRAINT "purchase_orders_approval_request_id_fkey" FOREIGN KEY ("approval_request_id") REFERENCES "approval_requests"("id") ON DELETE RESTRICT ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "purchase_orders" ADD CONSTRAINT "purchase_orders_supersedes_id_fkey" FOREIGN KEY ("supersedes_id") REFERENCES "purchase_orders"("id") ON DELETE RESTRICT ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "purchase_order_lines" ADD CONSTRAINT "purchase_order_lines_organization_id_fkey" FOREIGN KEY ("organization_id") REFERENCES "organizations"("id") ON DELETE RESTRICT ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "purchase_order_lines" ADD CONSTRAINT "purchase_order_lines_purchase_order_id_fkey" FOREIGN KEY ("purchase_order_id") REFERENCES "purchase_orders"("id") ON DELETE RESTRICT ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "purchase_order_lines" ADD CONSTRAINT "purchase_order_lines_indent_line_id_fkey" FOREIGN KEY ("indent_line_id") REFERENCES "indent_lines"("id") ON DELETE RESTRICT ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "purchase_order_lines" ADD CONSTRAINT "purchase_order_lines_material_id_fkey" FOREIGN KEY ("material_id") REFERENCES "materials"("id") ON DELETE RESTRICT ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "purchase_order_lines" ADD CONSTRAINT "purchase_order_lines_gst_rate_id_fkey" FOREIGN KEY ("gst_rate_id") REFERENCES "gst_rates"("id") ON DELETE RESTRICT ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "goods_receipts" ADD CONSTRAINT "goods_receipts_organization_id_fkey" FOREIGN KEY ("organization_id") REFERENCES "organizations"("id") ON DELETE RESTRICT ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "goods_receipts" ADD CONSTRAINT "goods_receipts_project_id_fkey" FOREIGN KEY ("project_id") REFERENCES "projects"("id") ON DELETE RESTRICT ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "goods_receipts" ADD CONSTRAINT "goods_receipts_store_id_fkey" FOREIGN KEY ("store_id") REFERENCES "stores"("id") ON DELETE RESTRICT ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "goods_receipts" ADD CONSTRAINT "goods_receipts_purchase_order_id_fkey" FOREIGN KEY ("purchase_order_id") REFERENCES "purchase_orders"("id") ON DELETE RESTRICT ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "goods_receipts" ADD CONSTRAINT "goods_receipts_vendor_party_id_fkey" FOREIGN KEY ("vendor_party_id") REFERENCES "parties"("id") ON DELETE RESTRICT ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "goods_receipts" ADD CONSTRAINT "goods_receipts_received_by_id_fkey" FOREIGN KEY ("received_by_id") REFERENCES "users"("id") ON DELETE RESTRICT ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "goods_receipt_lines" ADD CONSTRAINT "goods_receipt_lines_organization_id_fkey" FOREIGN KEY ("organization_id") REFERENCES "organizations"("id") ON DELETE RESTRICT ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "goods_receipt_lines" ADD CONSTRAINT "goods_receipt_lines_goods_receipt_id_fkey" FOREIGN KEY ("goods_receipt_id") REFERENCES "goods_receipts"("id") ON DELETE RESTRICT ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "goods_receipt_lines" ADD CONSTRAINT "goods_receipt_lines_purchase_order_line_id_fkey" FOREIGN KEY ("purchase_order_line_id") REFERENCES "purchase_order_lines"("id") ON DELETE RESTRICT ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "goods_receipt_lines" ADD CONSTRAINT "goods_receipt_lines_material_id_fkey" FOREIGN KEY ("material_id") REFERENCES "materials"("id") ON DELETE RESTRICT ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "vendor_invoices" ADD CONSTRAINT "vendor_invoices_organization_id_fkey" FOREIGN KEY ("organization_id") REFERENCES "organizations"("id") ON DELETE RESTRICT ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "vendor_invoices" ADD CONSTRAINT "vendor_invoices_project_id_fkey" FOREIGN KEY ("project_id") REFERENCES "projects"("id") ON DELETE RESTRICT ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "vendor_invoices" ADD CONSTRAINT "vendor_invoices_vendor_party_id_fkey" FOREIGN KEY ("vendor_party_id") REFERENCES "parties"("id") ON DELETE RESTRICT ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "vendor_invoices" ADD CONSTRAINT "vendor_invoices_purchase_order_id_fkey" FOREIGN KEY ("purchase_order_id") REFERENCES "purchase_orders"("id") ON DELETE RESTRICT ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "vendor_invoices" ADD CONSTRAINT "vendor_invoices_approval_request_id_fkey" FOREIGN KEY ("approval_request_id") REFERENCES "approval_requests"("id") ON DELETE RESTRICT ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "vendor_invoices" ADD CONSTRAINT "vendor_invoices_tds_section_id_fkey" FOREIGN KEY ("tds_section_id") REFERENCES "tds_sections"("id") ON DELETE RESTRICT ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "vendor_invoices" ADD CONSTRAINT "vendor_invoices_journal_entry_id_fkey" FOREIGN KEY ("journal_entry_id") REFERENCES "journal_entries"("id") ON DELETE RESTRICT ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "vendor_invoice_lines" ADD CONSTRAINT "vendor_invoice_lines_organization_id_fkey" FOREIGN KEY ("organization_id") REFERENCES "organizations"("id") ON DELETE RESTRICT ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "vendor_invoice_lines" ADD CONSTRAINT "vendor_invoice_lines_invoice_id_fkey" FOREIGN KEY ("invoice_id") REFERENCES "vendor_invoices"("id") ON DELETE RESTRICT ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "vendor_invoice_lines" ADD CONSTRAINT "vendor_invoice_lines_purchase_order_line_id_fkey" FOREIGN KEY ("purchase_order_line_id") REFERENCES "purchase_order_lines"("id") ON DELETE RESTRICT ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "vendor_invoice_lines" ADD CONSTRAINT "vendor_invoice_lines_material_id_fkey" FOREIGN KEY ("material_id") REFERENCES "materials"("id") ON DELETE RESTRICT ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "vendor_invoice_lines" ADD CONSTRAINT "vendor_invoice_lines_gst_rate_id_fkey" FOREIGN KEY ("gst_rate_id") REFERENCES "gst_rates"("id") ON DELETE RESTRICT ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "three_way_matches" ADD CONSTRAINT "three_way_matches_organization_id_fkey" FOREIGN KEY ("organization_id") REFERENCES "organizations"("id") ON DELETE RESTRICT ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "three_way_matches" ADD CONSTRAINT "three_way_matches_vendor_invoice_id_fkey" FOREIGN KEY ("vendor_invoice_id") REFERENCES "vendor_invoices"("id") ON DELETE RESTRICT ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "three_way_matches" ADD CONSTRAINT "three_way_matches_purchase_order_id_fkey" FOREIGN KEY ("purchase_order_id") REFERENCES "purchase_orders"("id") ON DELETE RESTRICT ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "three_way_matches" ADD CONSTRAINT "three_way_matches_matched_by_id_fkey" FOREIGN KEY ("matched_by_id") REFERENCES "users"("id") ON DELETE RESTRICT ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "three_way_match_lines" ADD CONSTRAINT "three_way_match_lines_organization_id_fkey" FOREIGN KEY ("organization_id") REFERENCES "organizations"("id") ON DELETE RESTRICT ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "three_way_match_lines" ADD CONSTRAINT "three_way_match_lines_match_id_fkey" FOREIGN KEY ("match_id") REFERENCES "three_way_matches"("id") ON DELETE RESTRICT ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "three_way_match_lines" ADD CONSTRAINT "three_way_match_lines_invoice_line_id_fkey" FOREIGN KEY ("invoice_line_id") REFERENCES "vendor_invoice_lines"("id") ON DELETE RESTRICT ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "three_way_match_lines" ADD CONSTRAINT "three_way_match_lines_po_line_id_fkey" FOREIGN KEY ("po_line_id") REFERENCES "purchase_order_lines"("id") ON DELETE RESTRICT ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "three_way_match_lines" ADD CONSTRAINT "three_way_match_lines_grn_line_id_fkey" FOREIGN KEY ("grn_line_id") REFERENCES "goods_receipt_lines"("id") ON DELETE RESTRICT ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "stock_ledger_entries" ADD CONSTRAINT "stock_ledger_entries_organization_id_fkey" FOREIGN KEY ("organization_id") REFERENCES "organizations"("id") ON DELETE RESTRICT ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "stock_ledger_entries" ADD CONSTRAINT "stock_ledger_entries_project_id_fkey" FOREIGN KEY ("project_id") REFERENCES "projects"("id") ON DELETE RESTRICT ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "stock_ledger_entries" ADD CONSTRAINT "stock_ledger_entries_store_id_fkey" FOREIGN KEY ("store_id") REFERENCES "stores"("id") ON DELETE RESTRICT ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "stock_ledger_entries" ADD CONSTRAINT "stock_ledger_entries_material_id_fkey" FOREIGN KEY ("material_id") REFERENCES "materials"("id") ON DELETE RESTRICT ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "stock_ledger_entries" ADD CONSTRAINT "stock_ledger_entries_approval_request_id_fkey" FOREIGN KEY ("approval_request_id") REFERENCES "approval_requests"("id") ON DELETE RESTRICT ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "material_issues" ADD CONSTRAINT "material_issues_organization_id_fkey" FOREIGN KEY ("organization_id") REFERENCES "organizations"("id") ON DELETE RESTRICT ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "material_issues" ADD CONSTRAINT "material_issues_project_id_fkey" FOREIGN KEY ("project_id") REFERENCES "projects"("id") ON DELETE RESTRICT ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "material_issues" ADD CONSTRAINT "material_issues_store_id_fkey" FOREIGN KEY ("store_id") REFERENCES "stores"("id") ON DELETE RESTRICT ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "material_issues" ADD CONSTRAINT "material_issues_work_order_id_fkey" FOREIGN KEY ("work_order_id") REFERENCES "work_orders"("id") ON DELETE RESTRICT ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "material_issues" ADD CONSTRAINT "material_issues_issued_by_id_fkey" FOREIGN KEY ("issued_by_id") REFERENCES "users"("id") ON DELETE RESTRICT ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "material_issue_lines" ADD CONSTRAINT "material_issue_lines_organization_id_fkey" FOREIGN KEY ("organization_id") REFERENCES "organizations"("id") ON DELETE RESTRICT ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "material_issue_lines" ADD CONSTRAINT "material_issue_lines_issue_id_fkey" FOREIGN KEY ("issue_id") REFERENCES "material_issues"("id") ON DELETE RESTRICT ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "material_issue_lines" ADD CONSTRAINT "material_issue_lines_material_id_fkey" FOREIGN KEY ("material_id") REFERENCES "materials"("id") ON DELETE RESTRICT ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "material_issue_lines" ADD CONSTRAINT "material_issue_lines_boq_item_id_fkey" FOREIGN KEY ("boq_item_id") REFERENCES "boq_items"("id") ON DELETE RESTRICT ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "workers" ADD CONSTRAINT "workers_organization_id_fkey" FOREIGN KEY ("organization_id") REFERENCES "organizations"("id") ON DELETE RESTRICT ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "workers" ADD CONSTRAINT "workers_contractor_party_id_fkey" FOREIGN KEY ("contractor_party_id") REFERENCES "parties"("id") ON DELETE RESTRICT ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "labour_attendances" ADD CONSTRAINT "labour_attendances_organization_id_fkey" FOREIGN KEY ("organization_id") REFERENCES "organizations"("id") ON DELETE RESTRICT ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "labour_attendances" ADD CONSTRAINT "labour_attendances_project_id_fkey" FOREIGN KEY ("project_id") REFERENCES "projects"("id") ON DELETE RESTRICT ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "labour_attendances" ADD CONSTRAINT "labour_attendances_worker_id_fkey" FOREIGN KEY ("worker_id") REFERENCES "workers"("id") ON DELETE RESTRICT ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "labour_attendances" ADD CONSTRAINT "labour_attendances_recorded_by_id_fkey" FOREIGN KEY ("recorded_by_id") REFERENCES "users"("id") ON DELETE RESTRICT ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "work_orders" ADD CONSTRAINT "work_orders_organization_id_fkey" FOREIGN KEY ("organization_id") REFERENCES "organizations"("id") ON DELETE RESTRICT ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "work_orders" ADD CONSTRAINT "work_orders_project_id_fkey" FOREIGN KEY ("project_id") REFERENCES "projects"("id") ON DELETE RESTRICT ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "work_orders" ADD CONSTRAINT "work_orders_contractor_party_id_fkey" FOREIGN KEY ("contractor_party_id") REFERENCES "parties"("id") ON DELETE RESTRICT ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "work_orders" ADD CONSTRAINT "work_orders_tds_section_id_fkey" FOREIGN KEY ("tds_section_id") REFERENCES "tds_sections"("id") ON DELETE RESTRICT ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "work_orders" ADD CONSTRAINT "work_orders_approval_request_id_fkey" FOREIGN KEY ("approval_request_id") REFERENCES "approval_requests"("id") ON DELETE RESTRICT ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "work_order_lines" ADD CONSTRAINT "work_order_lines_organization_id_fkey" FOREIGN KEY ("organization_id") REFERENCES "organizations"("id") ON DELETE RESTRICT ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "work_order_lines" ADD CONSTRAINT "work_order_lines_work_order_id_fkey" FOREIGN KEY ("work_order_id") REFERENCES "work_orders"("id") ON DELETE RESTRICT ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "work_order_lines" ADD CONSTRAINT "work_order_lines_boq_item_id_fkey" FOREIGN KEY ("boq_item_id") REFERENCES "boq_items"("id") ON DELETE RESTRICT ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "measurement_entries" ADD CONSTRAINT "measurement_entries_organization_id_fkey" FOREIGN KEY ("organization_id") REFERENCES "organizations"("id") ON DELETE RESTRICT ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "measurement_entries" ADD CONSTRAINT "measurement_entries_project_id_fkey" FOREIGN KEY ("project_id") REFERENCES "projects"("id") ON DELETE RESTRICT ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "measurement_entries" ADD CONSTRAINT "measurement_entries_work_order_line_id_fkey" FOREIGN KEY ("work_order_line_id") REFERENCES "work_order_lines"("id") ON DELETE RESTRICT ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "measurement_entries" ADD CONSTRAINT "measurement_entries_measured_by_id_fkey" FOREIGN KEY ("measured_by_id") REFERENCES "users"("id") ON DELETE RESTRICT ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "measurement_entries" ADD CONSTRAINT "measurement_entries_checked_by_id_fkey" FOREIGN KEY ("checked_by_id") REFERENCES "users"("id") ON DELETE RESTRICT ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "ra_bills" ADD CONSTRAINT "ra_bills_organization_id_fkey" FOREIGN KEY ("organization_id") REFERENCES "organizations"("id") ON DELETE RESTRICT ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "ra_bills" ADD CONSTRAINT "ra_bills_project_id_fkey" FOREIGN KEY ("project_id") REFERENCES "projects"("id") ON DELETE RESTRICT ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "ra_bills" ADD CONSTRAINT "ra_bills_work_order_id_fkey" FOREIGN KEY ("work_order_id") REFERENCES "work_orders"("id") ON DELETE RESTRICT ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "ra_bills" ADD CONSTRAINT "ra_bills_approval_request_id_fkey" FOREIGN KEY ("approval_request_id") REFERENCES "approval_requests"("id") ON DELETE RESTRICT ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "ra_bills" ADD CONSTRAINT "ra_bills_tds_section_id_fkey" FOREIGN KEY ("tds_section_id") REFERENCES "tds_sections"("id") ON DELETE RESTRICT ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "ra_bills" ADD CONSTRAINT "ra_bills_journal_entry_id_fkey" FOREIGN KEY ("journal_entry_id") REFERENCES "journal_entries"("id") ON DELETE RESTRICT ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "ra_bill_lines" ADD CONSTRAINT "ra_bill_lines_organization_id_fkey" FOREIGN KEY ("organization_id") REFERENCES "organizations"("id") ON DELETE RESTRICT ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "ra_bill_lines" ADD CONSTRAINT "ra_bill_lines_ra_bill_id_fkey" FOREIGN KEY ("ra_bill_id") REFERENCES "ra_bills"("id") ON DELETE RESTRICT ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "ra_bill_lines" ADD CONSTRAINT "ra_bill_lines_work_order_line_id_fkey" FOREIGN KEY ("work_order_line_id") REFERENCES "work_order_lines"("id") ON DELETE RESTRICT ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "ra_bill_lines" ADD CONSTRAINT "ra_bill_lines_measurement_entry_id_fkey" FOREIGN KEY ("measurement_entry_id") REFERENCES "measurement_entries"("id") ON DELETE RESTRICT ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "retention_entries" ADD CONSTRAINT "retention_entries_organization_id_fkey" FOREIGN KEY ("organization_id") REFERENCES "organizations"("id") ON DELETE RESTRICT ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "retention_entries" ADD CONSTRAINT "retention_entries_project_id_fkey" FOREIGN KEY ("project_id") REFERENCES "projects"("id") ON DELETE RESTRICT ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "retention_entries" ADD CONSTRAINT "retention_entries_contractor_party_id_fkey" FOREIGN KEY ("contractor_party_id") REFERENCES "parties"("id") ON DELETE RESTRICT ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "retention_entries" ADD CONSTRAINT "retention_entries_ra_bill_id_fkey" FOREIGN KEY ("ra_bill_id") REFERENCES "ra_bills"("id") ON DELETE RESTRICT ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "retention_entries" ADD CONSTRAINT "retention_entries_journal_entry_id_fkey" FOREIGN KEY ("journal_entry_id") REFERENCES "journal_entries"("id") ON DELETE RESTRICT ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "contractor_advances" ADD CONSTRAINT "contractor_advances_organization_id_fkey" FOREIGN KEY ("organization_id") REFERENCES "organizations"("id") ON DELETE RESTRICT ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "contractor_advances" ADD CONSTRAINT "contractor_advances_project_id_fkey" FOREIGN KEY ("project_id") REFERENCES "projects"("id") ON DELETE RESTRICT ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "contractor_advances" ADD CONSTRAINT "contractor_advances_work_order_id_fkey" FOREIGN KEY ("work_order_id") REFERENCES "work_orders"("id") ON DELETE RESTRICT ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "contractor_advances" ADD CONSTRAINT "contractor_advances_contractor_party_id_fkey" FOREIGN KEY ("contractor_party_id") REFERENCES "parties"("id") ON DELETE RESTRICT ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "contractor_advances" ADD CONSTRAINT "contractor_advances_journal_entry_id_fkey" FOREIGN KEY ("journal_entry_id") REFERENCES "journal_entries"("id") ON DELETE RESTRICT ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "advance_recoveries" ADD CONSTRAINT "advance_recoveries_organization_id_fkey" FOREIGN KEY ("organization_id") REFERENCES "organizations"("id") ON DELETE RESTRICT ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "advance_recoveries" ADD CONSTRAINT "advance_recoveries_project_id_fkey" FOREIGN KEY ("project_id") REFERENCES "projects"("id") ON DELETE RESTRICT ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "advance_recoveries" ADD CONSTRAINT "advance_recoveries_advance_id_fkey" FOREIGN KEY ("advance_id") REFERENCES "contractor_advances"("id") ON DELETE RESTRICT ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "advance_recoveries" ADD CONSTRAINT "advance_recoveries_ra_bill_id_fkey" FOREIGN KEY ("ra_bill_id") REFERENCES "ra_bills"("id") ON DELETE RESTRICT ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "advance_recoveries" ADD CONSTRAINT "advance_recoveries_journal_entry_id_fkey" FOREIGN KEY ("journal_entry_id") REFERENCES "journal_entries"("id") ON DELETE RESTRICT ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "gl_accounts" ADD CONSTRAINT "gl_accounts_organization_id_fkey" FOREIGN KEY ("organization_id") REFERENCES "organizations"("id") ON DELETE RESTRICT ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "gl_accounts" ADD CONSTRAINT "gl_accounts_parent_id_fkey" FOREIGN KEY ("parent_id") REFERENCES "gl_accounts"("id") ON DELETE RESTRICT ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "journal_entries" ADD CONSTRAINT "journal_entries_organization_id_fkey" FOREIGN KEY ("organization_id") REFERENCES "organizations"("id") ON DELETE RESTRICT ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "journal_entries" ADD CONSTRAINT "journal_entries_period_id_fkey" FOREIGN KEY ("period_id") REFERENCES "accounting_periods"("id") ON DELETE RESTRICT ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "journal_entries" ADD CONSTRAINT "journal_entries_posted_by_id_fkey" FOREIGN KEY ("posted_by_id") REFERENCES "users"("id") ON DELETE RESTRICT ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "journal_entries" ADD CONSTRAINT "journal_entries_reversal_of_id_fkey" FOREIGN KEY ("reversal_of_id") REFERENCES "journal_entries"("id") ON DELETE RESTRICT ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "journal_lines" ADD CONSTRAINT "journal_lines_organization_id_fkey" FOREIGN KEY ("organization_id") REFERENCES "organizations"("id") ON DELETE RESTRICT ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "journal_lines" ADD CONSTRAINT "journal_lines_entry_id_fkey" FOREIGN KEY ("entry_id") REFERENCES "journal_entries"("id") ON DELETE RESTRICT ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "journal_lines" ADD CONSTRAINT "journal_lines_gl_account_id_fkey" FOREIGN KEY ("gl_account_id") REFERENCES "gl_accounts"("id") ON DELETE RESTRICT ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "journal_lines" ADD CONSTRAINT "journal_lines_project_id_fkey" FOREIGN KEY ("project_id") REFERENCES "projects"("id") ON DELETE RESTRICT ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "journal_lines" ADD CONSTRAINT "journal_lines_cost_centre_id_fkey" FOREIGN KEY ("cost_centre_id") REFERENCES "cost_centres"("id") ON DELETE RESTRICT ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "journal_lines" ADD CONSTRAINT "journal_lines_unit_id_fkey" FOREIGN KEY ("unit_id") REFERENCES "units"("id") ON DELETE RESTRICT ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "journal_lines" ADD CONSTRAINT "journal_lines_party_id_fkey" FOREIGN KEY ("party_id") REFERENCES "parties"("id") ON DELETE RESTRICT ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "bank_accounts" ADD CONSTRAINT "bank_accounts_organization_id_fkey" FOREIGN KEY ("organization_id") REFERENCES "organizations"("id") ON DELETE RESTRICT ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "bank_accounts" ADD CONSTRAINT "bank_accounts_gl_account_id_fkey" FOREIGN KEY ("gl_account_id") REFERENCES "gl_accounts"("id") ON DELETE RESTRICT ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "bank_statement_imports" ADD CONSTRAINT "bank_statement_imports_organization_id_fkey" FOREIGN KEY ("organization_id") REFERENCES "organizations"("id") ON DELETE RESTRICT ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "bank_statement_imports" ADD CONSTRAINT "bank_statement_imports_bank_account_id_fkey" FOREIGN KEY ("bank_account_id") REFERENCES "bank_accounts"("id") ON DELETE RESTRICT ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "bank_statement_imports" ADD CONSTRAINT "bank_statement_imports_import_batch_id_fkey" FOREIGN KEY ("import_batch_id") REFERENCES "import_batches"("id") ON DELETE RESTRICT ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "bank_statement_imports" ADD CONSTRAINT "bank_statement_imports_document_id_fkey" FOREIGN KEY ("document_id") REFERENCES "documents"("id") ON DELETE RESTRICT ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "bank_statement_imports" ADD CONSTRAINT "bank_statement_imports_imported_by_id_fkey" FOREIGN KEY ("imported_by_id") REFERENCES "users"("id") ON DELETE RESTRICT ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "bank_statement_lines" ADD CONSTRAINT "bank_statement_lines_organization_id_fkey" FOREIGN KEY ("organization_id") REFERENCES "organizations"("id") ON DELETE RESTRICT ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "bank_statement_lines" ADD CONSTRAINT "bank_statement_lines_import_id_fkey" FOREIGN KEY ("import_id") REFERENCES "bank_statement_imports"("id") ON DELETE RESTRICT ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "bank_statement_lines" ADD CONSTRAINT "bank_statement_lines_bank_account_id_fkey" FOREIGN KEY ("bank_account_id") REFERENCES "bank_accounts"("id") ON DELETE RESTRICT ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "reconciliation_matches" ADD CONSTRAINT "reconciliation_matches_organization_id_fkey" FOREIGN KEY ("organization_id") REFERENCES "organizations"("id") ON DELETE RESTRICT ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "reconciliation_matches" ADD CONSTRAINT "reconciliation_matches_statement_line_id_fkey" FOREIGN KEY ("statement_line_id") REFERENCES "bank_statement_lines"("id") ON DELETE RESTRICT ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "reconciliation_matches" ADD CONSTRAINT "reconciliation_matches_journal_line_id_fkey" FOREIGN KEY ("journal_line_id") REFERENCES "journal_lines"("id") ON DELETE RESTRICT ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "reconciliation_matches" ADD CONSTRAINT "reconciliation_matches_matched_by_id_fkey" FOREIGN KEY ("matched_by_id") REFERENCES "users"("id") ON DELETE RESTRICT ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "budgets" ADD CONSTRAINT "budgets_organization_id_fkey" FOREIGN KEY ("organization_id") REFERENCES "organizations"("id") ON DELETE RESTRICT ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "budgets" ADD CONSTRAINT "budgets_project_id_fkey" FOREIGN KEY ("project_id") REFERENCES "projects"("id") ON DELETE RESTRICT ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "budgets" ADD CONSTRAINT "budgets_supersedes_id_fkey" FOREIGN KEY ("supersedes_id") REFERENCES "budgets"("id") ON DELETE RESTRICT ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "budget_lines" ADD CONSTRAINT "budget_lines_organization_id_fkey" FOREIGN KEY ("organization_id") REFERENCES "organizations"("id") ON DELETE RESTRICT ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "budget_lines" ADD CONSTRAINT "budget_lines_budget_id_fkey" FOREIGN KEY ("budget_id") REFERENCES "budgets"("id") ON DELETE RESTRICT ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "budget_lines" ADD CONSTRAINT "budget_lines_cost_centre_id_fkey" FOREIGN KEY ("cost_centre_id") REFERENCES "cost_centres"("id") ON DELETE RESTRICT ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "budget_lines" ADD CONSTRAINT "budget_lines_gl_account_id_fkey" FOREIGN KEY ("gl_account_id") REFERENCES "gl_accounts"("id") ON DELETE RESTRICT ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "budget_lines" ADD CONSTRAINT "budget_lines_boq_item_id_fkey" FOREIGN KEY ("boq_item_id") REFERENCES "boq_items"("id") ON DELETE RESTRICT ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "loans" ADD CONSTRAINT "loans_organization_id_fkey" FOREIGN KEY ("organization_id") REFERENCES "organizations"("id") ON DELETE RESTRICT ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "loans" ADD CONSTRAINT "loans_project_id_fkey" FOREIGN KEY ("project_id") REFERENCES "projects"("id") ON DELETE RESTRICT ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "loans" ADD CONSTRAINT "loans_lender_party_id_fkey" FOREIGN KEY ("lender_party_id") REFERENCES "parties"("id") ON DELETE RESTRICT ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "loans" ADD CONSTRAINT "loans_gl_account_id_fkey" FOREIGN KEY ("gl_account_id") REFERENCES "gl_accounts"("id") ON DELETE RESTRICT ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "loan_interest_accruals" ADD CONSTRAINT "loan_interest_accruals_organization_id_fkey" FOREIGN KEY ("organization_id") REFERENCES "organizations"("id") ON DELETE RESTRICT ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "loan_interest_accruals" ADD CONSTRAINT "loan_interest_accruals_loan_id_fkey" FOREIGN KEY ("loan_id") REFERENCES "loans"("id") ON DELETE RESTRICT ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "loan_interest_accruals" ADD CONSTRAINT "loan_interest_accruals_recorded_by_id_fkey" FOREIGN KEY ("recorded_by_id") REFERENCES "users"("id") ON DELETE RESTRICT ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "loan_interest_accruals" ADD CONSTRAINT "loan_interest_accruals_journal_entry_id_fkey" FOREIGN KEY ("journal_entry_id") REFERENCES "journal_entries"("id") ON DELETE RESTRICT ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "loan_interest_accruals" ADD CONSTRAINT "loan_interest_accruals_reversal_of_id_fkey" FOREIGN KEY ("reversal_of_id") REFERENCES "loan_interest_accruals"("id") ON DELETE RESTRICT ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "loan_transactions" ADD CONSTRAINT "loan_transactions_organization_id_fkey" FOREIGN KEY ("organization_id") REFERENCES "organizations"("id") ON DELETE RESTRICT ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "loan_transactions" ADD CONSTRAINT "loan_transactions_loan_id_fkey" FOREIGN KEY ("loan_id") REFERENCES "loans"("id") ON DELETE RESTRICT ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "loan_transactions" ADD CONSTRAINT "loan_transactions_journal_entry_id_fkey" FOREIGN KEY ("journal_entry_id") REFERENCES "journal_entries"("id") ON DELETE RESTRICT ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "emi_schedules" ADD CONSTRAINT "emi_schedules_organization_id_fkey" FOREIGN KEY ("organization_id") REFERENCES "organizations"("id") ON DELETE RESTRICT ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "emi_schedules" ADD CONSTRAINT "emi_schedules_loan_id_fkey" FOREIGN KEY ("loan_id") REFERENCES "loans"("id") ON DELETE RESTRICT ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "emi_schedules" ADD CONSTRAINT "emi_schedules_supersedes_id_fkey" FOREIGN KEY ("supersedes_id") REFERENCES "emi_schedules"("id") ON DELETE RESTRICT ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "emi_schedule_lines" ADD CONSTRAINT "emi_schedule_lines_organization_id_fkey" FOREIGN KEY ("organization_id") REFERENCES "organizations"("id") ON DELETE RESTRICT ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "emi_schedule_lines" ADD CONSTRAINT "emi_schedule_lines_schedule_id_fkey" FOREIGN KEY ("schedule_id") REFERENCES "emi_schedules"("id") ON DELETE RESTRICT ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "emi_schedule_lines" ADD CONSTRAINT "emi_schedule_lines_loan_transaction_id_fkey" FOREIGN KEY ("loan_transaction_id") REFERENCES "loan_transactions"("id") ON DELETE RESTRICT ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "payments" ADD CONSTRAINT "payments_organization_id_fkey" FOREIGN KEY ("organization_id") REFERENCES "organizations"("id") ON DELETE RESTRICT ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "payments" ADD CONSTRAINT "payments_project_id_fkey" FOREIGN KEY ("project_id") REFERENCES "projects"("id") ON DELETE RESTRICT ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "payments" ADD CONSTRAINT "payments_party_id_fkey" FOREIGN KEY ("party_id") REFERENCES "parties"("id") ON DELETE RESTRICT ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "payments" ADD CONSTRAINT "payments_bank_account_id_fkey" FOREIGN KEY ("bank_account_id") REFERENCES "bank_accounts"("id") ON DELETE RESTRICT ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "payments" ADD CONSTRAINT "payments_prepared_by_id_fkey" FOREIGN KEY ("prepared_by_id") REFERENCES "users"("id") ON DELETE RESTRICT ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "payments" ADD CONSTRAINT "payments_approval_request_id_fkey" FOREIGN KEY ("approval_request_id") REFERENCES "approval_requests"("id") ON DELETE RESTRICT ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "payments" ADD CONSTRAINT "payments_journal_entry_id_fkey" FOREIGN KEY ("journal_entry_id") REFERENCES "journal_entries"("id") ON DELETE RESTRICT ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "payment_allocations" ADD CONSTRAINT "payment_allocations_organization_id_fkey" FOREIGN KEY ("organization_id") REFERENCES "organizations"("id") ON DELETE RESTRICT ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "payment_allocations" ADD CONSTRAINT "payment_allocations_payment_id_fkey" FOREIGN KEY ("payment_id") REFERENCES "payments"("id") ON DELETE RESTRICT ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "payment_allocations" ADD CONSTRAINT "payment_allocations_vendor_invoice_id_fkey" FOREIGN KEY ("vendor_invoice_id") REFERENCES "vendor_invoices"("id") ON DELETE RESTRICT ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "payment_allocations" ADD CONSTRAINT "payment_allocations_ra_bill_id_fkey" FOREIGN KEY ("ra_bill_id") REFERENCES "ra_bills"("id") ON DELETE RESTRICT ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "payment_allocations" ADD CONSTRAINT "payment_allocations_loan_transaction_id_fkey" FOREIGN KEY ("loan_transaction_id") REFERENCES "loan_transactions"("id") ON DELETE RESTRICT ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "payment_allocations" ADD CONSTRAINT "payment_allocations_contractor_advance_id_fkey" FOREIGN KEY ("contractor_advance_id") REFERENCES "contractor_advances"("id") ON DELETE RESTRICT ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "payment_allocations" ADD CONSTRAINT "payment_allocations_booking_cancellation_id_fkey" FOREIGN KEY ("booking_cancellation_id") REFERENCES "booking_cancellations"("id") ON DELETE RESTRICT ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "payment_allocations" ADD CONSTRAINT "payment_allocations_retention_entry_id_fkey" FOREIGN KEY ("retention_entry_id") REFERENCES "retention_entries"("id") ON DELETE RESTRICT ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "payment_source_links" ADD CONSTRAINT "payment_source_links_organization_id_fkey" FOREIGN KEY ("organization_id") REFERENCES "organizations"("id") ON DELETE RESTRICT ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "payment_source_links" ADD CONSTRAINT "payment_source_links_payment_id_fkey" FOREIGN KEY ("payment_id") REFERENCES "payments"("id") ON DELETE RESTRICT ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "payment_source_links" ADD CONSTRAINT "payment_source_links_document_id_fkey" FOREIGN KEY ("document_id") REFERENCES "documents"("id") ON DELETE RESTRICT ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "tally_ledger_maps" ADD CONSTRAINT "tally_ledger_maps_organization_id_fkey" FOREIGN KEY ("organization_id") REFERENCES "organizations"("id") ON DELETE RESTRICT ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "tally_ledger_maps" ADD CONSTRAINT "tally_ledger_maps_gl_account_id_fkey" FOREIGN KEY ("gl_account_id") REFERENCES "gl_accounts"("id") ON DELETE RESTRICT ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "import_batches" ADD CONSTRAINT "import_batches_organization_id_fkey" FOREIGN KEY ("organization_id") REFERENCES "organizations"("id") ON DELETE RESTRICT ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "import_batches" ADD CONSTRAINT "import_batches_created_by_id_fkey" FOREIGN KEY ("created_by_id") REFERENCES "users"("id") ON DELETE RESTRICT ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "import_batches" ADD CONSTRAINT "import_batches_document_id_fkey" FOREIGN KEY ("document_id") REFERENCES "documents"("id") ON DELETE RESTRICT ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "documents" ADD CONSTRAINT "documents_organization_id_fkey" FOREIGN KEY ("organization_id") REFERENCES "organizations"("id") ON DELETE RESTRICT ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "documents" ADD CONSTRAINT "documents_uploaded_by_id_fkey" FOREIGN KEY ("uploaded_by_id") REFERENCES "users"("id") ON DELETE RESTRICT ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "ocr_extractions" ADD CONSTRAINT "ocr_extractions_organization_id_fkey" FOREIGN KEY ("organization_id") REFERENCES "organizations"("id") ON DELETE RESTRICT ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "ocr_extractions" ADD CONSTRAINT "ocr_extractions_document_id_fkey" FOREIGN KEY ("document_id") REFERENCES "documents"("id") ON DELETE RESTRICT ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "exception_rules" ADD CONSTRAINT "exception_rules_organization_id_fkey" FOREIGN KEY ("organization_id") REFERENCES "organizations"("id") ON DELETE RESTRICT ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "exception_items" ADD CONSTRAINT "exception_items_organization_id_fkey" FOREIGN KEY ("organization_id") REFERENCES "organizations"("id") ON DELETE RESTRICT ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "exception_items" ADD CONSTRAINT "exception_items_project_id_fkey" FOREIGN KEY ("project_id") REFERENCES "projects"("id") ON DELETE RESTRICT ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "exception_items" ADD CONSTRAINT "exception_items_rule_id_fkey" FOREIGN KEY ("rule_id") REFERENCES "exception_rules"("id") ON DELETE RESTRICT ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "exception_items" ADD CONSTRAINT "exception_items_acknowledged_by_id_fkey" FOREIGN KEY ("acknowledged_by_id") REFERENCES "users"("id") ON DELETE RESTRICT ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "exception_items" ADD CONSTRAINT "exception_items_resolved_by_id_fkey" FOREIGN KEY ("resolved_by_id") REFERENCES "users"("id") ON DELETE RESTRICT ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "notifications" ADD CONSTRAINT "notifications_organization_id_fkey" FOREIGN KEY ("organization_id") REFERENCES "organizations"("id") ON DELETE RESTRICT ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "notifications" ADD CONSTRAINT "notifications_user_id_fkey" FOREIGN KEY ("user_id") REFERENCES "users"("id") ON DELETE RESTRICT ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "sync_mutations" ADD CONSTRAINT "sync_mutations_organization_id_fkey" FOREIGN KEY ("organization_id") REFERENCES "organizations"("id") ON DELETE RESTRICT ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "sync_mutations" ADD CONSTRAINT "sync_mutations_device_id_fkey" FOREIGN KEY ("device_id") REFERENCES "devices"("id") ON DELETE RESTRICT ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "search_documents" ADD CONSTRAINT "search_documents_organization_id_fkey" FOREIGN KEY ("organization_id") REFERENCES "organizations"("id") ON DELETE RESTRICT ON UPDATE CASCADE;

