-- Check constraints and partial unique indexes Prisma cannot express.
-- Not applied in step 1. Run as the table owner after prisma migrate.
-- Names are stable so a later migration can drop them by name.

-- One active PAN and one active GSTIN per firm. A soft-deleted row releases the key.
CREATE UNIQUE INDEX IF NOT EXISTS parties_org_pan_active
  ON parties (organization_id, pan_normalized)
  WHERE pan_normalized IS NOT NULL AND deleted_at IS NULL;

CREATE UNIQUE INDEX IF NOT EXISTS parties_org_gstin_active
  ON parties (organization_id, gstin_normalized)
  WHERE gstin_normalized IS NOT NULL AND deleted_at IS NULL;

-- Phone and bank fingerprint stay non-unique. A shared number raises an
-- exception item. It does not block the save.

ALTER TABLE memberships DROP CONSTRAINT IF EXISTS memberships_role_party;
ALTER TABLE memberships ADD CONSTRAINT memberships_role_party CHECK (
  (role IN ('VENDOR', 'CUSTOMER') AND party_id IS NOT NULL)
  OR (role IN ('FINANCE', 'PROJECT_MANAGER', 'SITE_ENGINEER', 'SALES', 'AUDITOR') AND party_id IS NULL)
  OR role = 'OWNER'
);

ALTER TABLE interest_rules DROP CONSTRAINT IF EXISTS interest_rules_simple_only;
ALTER TABLE interest_rules ADD CONSTRAINT interest_rules_simple_only CHECK (compound = false);

ALTER TABLE journal_lines DROP CONSTRAINT IF EXISTS journal_lines_one_side;
ALTER TABLE journal_lines ADD CONSTRAINT journal_lines_one_side CHECK (
  debit_paise >= 0
  AND credit_paise >= 0
  AND NOT (debit_paise > 0 AND credit_paise > 0)
  AND (debit_paise > 0 OR credit_paise > 0)
);

ALTER TABLE journal_entries DROP CONSTRAINT IF EXISTS journal_entries_posted_hash;
ALTER TABLE journal_entries ADD CONSTRAINT journal_entries_posted_hash CHECK (
  (
    status = 'DRAFT'
    AND sequence IS NULL
    AND prev_hash IS NULL
    AND entry_hash IS NULL
  )
  OR (
    status IN ('POSTED', 'REVERSED')
    AND sequence IS NOT NULL
    AND prev_hash ~ '^[0-9a-f]{64}$'
    AND entry_hash ~ '^[0-9a-f]{64}$'
  )
);

ALTER TABLE bookings DROP CONSTRAINT IF EXISTS bookings_total;
ALTER TABLE bookings ADD CONSTRAINT bookings_total CHECK (
  total_payable_paise = base_value_paise + cgst_paise + sgst_paise + igst_paise + cess_paise + charges_paise + charges_gst_paise
);

ALTER TABLE bookings DROP CONSTRAINT IF EXISTS bookings_gst_side;
ALTER TABLE bookings ADD CONSTRAINT bookings_gst_side CHECK (
  (supply_type = 'INTRA_STATE' AND igst_paise = 0)
  OR (supply_type = 'INTER_STATE' AND cgst_paise = 0 AND sgst_paise = 0)
);

ALTER TABLE demand_notes DROP CONSTRAINT IF EXISTS demand_notes_total;
ALTER TABLE demand_notes ADD CONSTRAINT demand_notes_total CHECK (
  total_paise = base_paise + cgst_paise + sgst_paise + igst_paise + cess_paise + round_off_paise
);

ALTER TABLE demand_notes DROP CONSTRAINT IF EXISTS demand_notes_gst_side;
ALTER TABLE demand_notes ADD CONSTRAINT demand_notes_gst_side CHECK (
  (supply_type = 'INTRA_STATE' AND igst_paise = 0)
  OR (supply_type = 'INTER_STATE' AND cgst_paise = 0 AND sgst_paise = 0)
);

ALTER TABLE demand_schedule_items DROP CONSTRAINT IF EXISTS demand_schedule_total;
ALTER TABLE demand_schedule_items ADD CONSTRAINT demand_schedule_total CHECK (
  total_paise = base_paise + cgst_paise + sgst_paise + igst_paise + cess_paise
);

ALTER TABLE vendor_invoices DROP CONSTRAINT IF EXISTS vendor_invoices_total;
ALTER TABLE vendor_invoices ADD CONSTRAINT vendor_invoices_total CHECK (
  total_paise = taxable_paise + cgst_paise + sgst_paise + igst_paise + cess_paise + round_off_paise
);

ALTER TABLE vendor_invoices DROP CONSTRAINT IF EXISTS vendor_invoices_net;
ALTER TABLE vendor_invoices ADD CONSTRAINT vendor_invoices_net CHECK (
  net_payable_paise = total_paise - tds_paise
);

ALTER TABLE vendor_invoices DROP CONSTRAINT IF EXISTS vendor_invoices_gst_side;
ALTER TABLE vendor_invoices ADD CONSTRAINT vendor_invoices_gst_side CHECK (
  (supply_type = 'INTRA_STATE' AND igst_paise = 0)
  OR (supply_type = 'INTER_STATE' AND cgst_paise = 0 AND sgst_paise = 0)
);

ALTER TABLE ra_bills DROP CONSTRAINT IF EXISTS ra_bills_net;
ALTER TABLE ra_bills ADD CONSTRAINT ra_bills_net CHECK (
  net_payable_paise = gross_paise
    + cgst_paise + sgst_paise + igst_paise + cess_paise
    + round_off_paise
    - retention_paise
    - advance_recovery_paise
    - tds_paise
    - other_deduction_paise
);

ALTER TABLE ra_bills DROP CONSTRAINT IF EXISTS ra_bills_gst_side;
ALTER TABLE ra_bills ADD CONSTRAINT ra_bills_gst_side CHECK (
  (supply_type = 'INTRA_STATE' AND igst_paise = 0)
  OR (supply_type = 'INTER_STATE' AND cgst_paise = 0 AND sgst_paise = 0)
);

ALTER TABLE customer_statements DROP CONSTRAINT IF EXISTS customer_statements_closing;
ALTER TABLE customer_statements ADD CONSTRAINT customer_statements_closing CHECK (
  closing_paise = opening_paise + demands_paise + interest_paise - receipts_paise - refunds_paise
);

ALTER TABLE payment_allocations DROP CONSTRAINT IF EXISTS payment_allocations_one_target;
ALTER TABLE payment_allocations ADD CONSTRAINT payment_allocations_one_target CHECK (
  (vendor_invoice_id IS NOT NULL)::int
  + (ra_bill_id IS NOT NULL)::int
  + (loan_transaction_id IS NOT NULL)::int
  + (contractor_advance_id IS NOT NULL)::int
  + (booking_cancellation_id IS NOT NULL)::int
  + (retention_entry_id IS NOT NULL)::int
  = 1
);

ALTER TABLE payments DROP CONSTRAINT IF EXISTS payments_approved_have_approval;
ALTER TABLE payments ADD CONSTRAINT payments_approved_have_approval CHECK (
  status NOT IN ('APPROVED', 'PAID') OR approval_request_id IS NOT NULL
);

ALTER TABLE period_lock_events DROP CONSTRAINT IF EXISTS period_reopen_has_approval;
ALTER TABLE period_lock_events ADD CONSTRAINT period_reopen_has_approval CHECK (
  action <> 'REOPEN' OR approval_request_id IS NOT NULL
);

ALTER TABLE audit_events DROP CONSTRAINT IF EXISTS audit_events_hash_shape;
ALTER TABLE audit_events ADD CONSTRAINT audit_events_hash_shape CHECK (
  prev_hash ~ '^[0-9a-f]{64}$' AND event_hash ~ '^[0-9a-f]{64}$'
);

ALTER TABLE stock_ledger_entries DROP CONSTRAINT IF EXISTS stock_ledger_hash_shape;
ALTER TABLE stock_ledger_entries ADD CONSTRAINT stock_ledger_hash_shape CHECK (
  prev_hash ~ '^[0-9a-f]{64}$' AND entry_hash ~ '^[0-9a-f]{64}$'
);

ALTER TABLE share_ledger_entries DROP CONSTRAINT IF EXISTS share_ledger_hash_shape;
ALTER TABLE share_ledger_entries ADD CONSTRAINT share_ledger_hash_shape CHECK (
  prev_hash ~ '^[0-9a-f]{64}$' AND entry_hash ~ '^[0-9a-f]{64}$'
);

-- A payment cannot become approved or paid until a source document is linked.
-- Deferred so the link and the status can be written in one transaction.
CREATE OR REPLACE FUNCTION app.payment_requires_source() RETURNS trigger
LANGUAGE plpgsql AS $$
BEGIN
  IF NEW.status IN ('APPROVED', 'PAID') THEN
    IF NOT EXISTS (
      SELECT 1 FROM payment_source_links link
      WHERE link.payment_id = NEW.id
        AND link.organization_id = NEW.organization_id
    ) THEN
      RAISE EXCEPTION 'a payment needs a source document before it can be approved or paid';
    END IF;
  END IF;
  RETURN NEW;
END;
$$;

DROP TRIGGER IF EXISTS payment_requires_source ON payments;
CREATE CONSTRAINT TRIGGER payment_requires_source
  AFTER INSERT OR UPDATE OF status ON payments
  DEFERRABLE INITIALLY DEFERRED
  FOR EACH ROW EXECUTE FUNCTION app.payment_requires_source();

-- Posting into a locked period is rejected. Soft-closed still posts.
-- Reopening the period is a separate, owner-approved event.
CREATE OR REPLACE FUNCTION app.reject_locked_period_post() RETURNS trigger
LANGUAGE plpgsql AS $$
DECLARE
  period_status text;
BEGIN
  IF NEW.status = 'POSTED' AND (TG_OP = 'INSERT' OR OLD.status IS DISTINCT FROM 'POSTED') THEN
    SELECT status INTO period_status FROM accounting_periods WHERE id = NEW.period_id;
    IF period_status = 'LOCKED' THEN
      RAISE EXCEPTION 'this accounting period is locked';
    END IF;
  END IF;
  RETURN NEW;
END;
$$;

DROP TRIGGER IF EXISTS reject_locked_period_post ON journal_entries;
CREATE TRIGGER reject_locked_period_post
  BEFORE INSERT OR UPDATE OF status, period_id ON journal_entries
  FOR EACH ROW EXECUTE FUNCTION app.reject_locked_period_post();
