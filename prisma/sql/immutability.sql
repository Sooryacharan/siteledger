-- Append-only tables, and the few columns that may still change after posting.
-- Not applied in step 1. Run as the table owner after prisma migrate.
-- siteledger_app has no DELETE grant. These triggers are the second lock,
-- so a future grant cannot quietly erase a money row.

CREATE OR REPLACE FUNCTION app.reject_mutation() RETURNS trigger
LANGUAGE plpgsql AS $$
BEGIN
  RAISE EXCEPTION '% is append-only. Correct it with a reversal row.', TG_TABLE_NAME
    USING ERRCODE = 'integrity_constraint_violation';
END;
$$;

DO $$
DECLARE
  append_only text[] := ARRAY[
    'audit_events',
    'approval_actions',
    'period_lock_events',
    'unit_area_revisions',
    'interest_accruals',
    'loan_interest_accruals',
    'customer_statements',
    'capital_contributions',
    'share_ledger_entries',
    'stock_ledger_entries',
    'retention_entries',
    'advance_recoveries',
    'lead_activities',
    'quote_comparisons'
  ];
  table_name text;
BEGIN
  FOREACH table_name IN ARRAY append_only LOOP
    EXECUTE format('DROP TRIGGER IF EXISTS append_only_update ON %I', table_name);
    EXECUTE format('DROP TRIGGER IF EXISTS append_only_delete ON %I', table_name);
    EXECUTE format(
      'CREATE TRIGGER append_only_update BEFORE UPDATE ON %I FOR EACH ROW EXECUTE FUNCTION app.reject_mutation()',
      table_name
    );
    EXECUTE format(
      'CREATE TRIGGER append_only_delete BEFORE DELETE ON %I FOR EACH ROW EXECUTE FUNCTION app.reject_mutation()',
      table_name
    );
  END LOOP;
END $$;

-- A posted journal may only move to reversed. The hashed columns stay put.
-- Status is not part of journal.v1, so the hash does not need to change.
CREATE OR REPLACE FUNCTION app.journal_entry_immutable() RETURNS trigger
LANGUAGE plpgsql AS $$
BEGIN
  IF TG_OP = 'DELETE' THEN
    RAISE EXCEPTION 'journal entries are not deleted';
  END IF;
  IF OLD.status = 'REVERSED' THEN
    RAISE EXCEPTION 'a reversed journal entry cannot change';
  END IF;
  IF OLD.status = 'POSTED' THEN
    IF NEW.status NOT IN ('POSTED', 'REVERSED') THEN
      RAISE EXCEPTION 'a posted journal entry can only be marked reversed';
    END IF;
    IF NEW.organization_id IS DISTINCT FROM OLD.organization_id
      OR NEW.period_id IS DISTINCT FROM OLD.period_id
      OR NEW.entry_number IS DISTINCT FROM OLD.entry_number
      OR NEW.entry_date IS DISTINCT FROM OLD.entry_date
      OR NEW.narration IS DISTINCT FROM OLD.narration
      OR NEW.source IS DISTINCT FROM OLD.source
      OR NEW.source_id IS DISTINCT FROM OLD.source_id
      OR NEW.reversal_of_id IS DISTINCT FROM OLD.reversal_of_id
      OR NEW.sequence IS DISTINCT FROM OLD.sequence
      OR NEW.prev_hash IS DISTINCT FROM OLD.prev_hash
      OR NEW.entry_hash IS DISTINCT FROM OLD.entry_hash
      OR NEW.idempotency_key IS DISTINCT FROM OLD.idempotency_key
      OR NEW.posted_at IS DISTINCT FROM OLD.posted_at
      OR NEW.posted_by_id IS DISTINCT FROM OLD.posted_by_id
    THEN
      RAISE EXCEPTION 'posted journal payload is immutable';
    END IF;
  END IF;
  RETURN NEW;
END;
$$;

DROP TRIGGER IF EXISTS journal_entry_immutable ON journal_entries;
CREATE TRIGGER journal_entry_immutable
  BEFORE UPDATE OR DELETE ON journal_entries
  FOR EACH ROW EXECUTE FUNCTION app.journal_entry_immutable();

CREATE OR REPLACE FUNCTION app.journal_line_immutable() RETURNS trigger
LANGUAGE plpgsql AS $$
DECLARE
  parent_status text;
  parent_id uuid;
BEGIN
  parent_id := CASE WHEN TG_OP = 'DELETE' THEN OLD.entry_id ELSE NEW.entry_id END;
  SELECT status INTO parent_status FROM journal_entries WHERE id = parent_id;
  IF parent_status IN ('POSTED', 'REVERSED') THEN
    RAISE EXCEPTION 'lines of a posted journal entry cannot change';
  END IF;
  IF TG_OP = 'UPDATE' AND OLD.entry_id IS DISTINCT FROM NEW.entry_id THEN
    SELECT status INTO parent_status FROM journal_entries WHERE id = OLD.entry_id;
    IF parent_status IN ('POSTED', 'REVERSED') THEN
      RAISE EXCEPTION 'lines of a posted journal entry cannot change';
    END IF;
  END IF;
  RETURN COALESCE(NEW, OLD);
END;
$$;

DROP TRIGGER IF EXISTS journal_line_immutable ON journal_lines;
CREATE TRIGGER journal_line_immutable
  BEFORE UPDATE OR DELETE ON journal_lines
  FOR EACH ROW EXECUTE FUNCTION app.journal_line_immutable();

-- EMI amounts stay. Status may move as the installment is paid or superseded.
CREATE OR REPLACE FUNCTION app.emi_line_amounts_immutable() RETURNS trigger
LANGUAGE plpgsql AS $$
BEGIN
  IF TG_OP = 'DELETE' THEN
    RAISE EXCEPTION 'EMI lines are not deleted';
  END IF;
  IF NEW.opening_principal_paise IS DISTINCT FROM OLD.opening_principal_paise
    OR NEW.principal_paise IS DISTINCT FROM OLD.principal_paise
    OR NEW.interest_paise IS DISTINCT FROM OLD.interest_paise
    OR NEW.emi_paise IS DISTINCT FROM OLD.emi_paise
    OR NEW.closing_principal_paise IS DISTINCT FROM OLD.closing_principal_paise
    OR NEW.installment_number IS DISTINCT FROM OLD.installment_number
    OR NEW.due_on IS DISTINCT FROM OLD.due_on
    OR NEW.schedule_id IS DISTINCT FROM OLD.schedule_id
  THEN
    RAISE EXCEPTION 'EMI line amounts are immutable. A prepayment creates a new schedule.';
  END IF;
  RETURN NEW;
END;
$$;

DROP TRIGGER IF EXISTS emi_line_amounts_immutable ON emi_schedule_lines;
CREATE TRIGGER emi_line_amounts_immutable
  BEFORE UPDATE OR DELETE ON emi_schedule_lines
  FOR EACH ROW EXECUTE FUNCTION app.emi_line_amounts_immutable();

-- A share computation may be superseded once. The profit figure stays.
CREATE OR REPLACE FUNCTION app.share_computation_immutable() RETURNS trigger
LANGUAGE plpgsql AS $$
BEGIN
  IF TG_OP = 'DELETE' THEN
    RAISE EXCEPTION 'share computations are not deleted';
  END IF;
  IF OLD.superseded_at IS NOT NULL AND NEW.superseded_at IS DISTINCT FROM OLD.superseded_at THEN
    RAISE EXCEPTION 'a superseded share computation cannot change again';
  END IF;
  IF NEW.profit_paise IS DISTINCT FROM OLD.profit_paise
    OR NEW.formula_version IS DISTINCT FROM OLD.formula_version
    OR NEW.agreement_id IS DISTINCT FROM OLD.agreement_id
    OR NEW.as_of IS DISTINCT FROM OLD.as_of
    OR NEW.project_id IS DISTINCT FROM OLD.project_id
    OR NEW.journal_entry_id IS DISTINCT FROM OLD.journal_entry_id
  THEN
    RAISE EXCEPTION 'share computation inputs are immutable';
  END IF;
  IF OLD.status = 'SUPERSEDED' AND NEW.status IS DISTINCT FROM 'SUPERSEDED' THEN
    RAISE EXCEPTION 'a superseded share computation stays superseded';
  END IF;
  RETURN NEW;
END;
$$;

DROP TRIGGER IF EXISTS share_computation_immutable ON share_computations;
CREATE TRIGGER share_computation_immutable
  BEFORE UPDATE OR DELETE ON share_computations
  FOR EACH ROW EXECUTE FUNCTION app.share_computation_immutable();
