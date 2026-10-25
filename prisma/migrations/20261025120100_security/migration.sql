-- Step 3 security. The four scripts below are the step 1 SQL, applied unchanged.
-- prisma/sql/rls.sql
-- SiteLedger row-level security.
-- Not applied in step 1. Run this as the table owner after `prisma migrate`.
-- PostgreSQL 16 is assumed, because the reporting views use security_invoker.
--
-- The application connects as siteledger_app. That role is not the table owner,
-- has no DELETE grant, and has no BYPASSRLS. RLS is enabled but not forced, so
-- the migration owner can still maintain the database.
--
-- Before each transaction the app sets:
--   app.organization_id  uuid of the firm
--   app.user_id          uuid of the person
--   app.role             OWNER, FINANCE, PROJECT_MANAGER, SITE_ENGINEER,
--                        SALES, VENDOR, CUSTOMER, or AUDITOR
--   app.party_id         uuid of the vendor or customer party, when the role has one
--
-- A missing or blank setting fails closed. Owner, finance, and auditor see the
-- whole firm. Project manager, site engineer, and sales also need a live
-- project assignment. Vendor and customer see only their own party. The
-- auditor cannot insert or update, except an audit_events row for an export.

CREATE SCHEMA IF NOT EXISTS app;

DO $$
BEGIN
  IF NOT EXISTS (SELECT 1 FROM pg_roles WHERE rolname = 'siteledger_app') THEN
    CREATE ROLE siteledger_app NOLOGIN;
  END IF;
END $$;

CREATE OR REPLACE FUNCTION app.organization_id() RETURNS uuid
LANGUAGE sql STABLE AS $$
  SELECT CASE
    WHEN current_setting('app.organization_id', true) ~* '^[0-9a-f]{8}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{12}$'
    THEN current_setting('app.organization_id', true)::uuid
    ELSE NULL
  END
$$;

CREATE OR REPLACE FUNCTION app.user_id() RETURNS uuid
LANGUAGE sql STABLE AS $$
  SELECT CASE
    WHEN current_setting('app.user_id', true) ~* '^[0-9a-f]{8}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{12}$'
    THEN current_setting('app.user_id', true)::uuid
    ELSE NULL
  END
$$;

CREATE OR REPLACE FUNCTION app.party_id() RETURNS uuid
LANGUAGE sql STABLE AS $$
  SELECT CASE
    WHEN current_setting('app.party_id', true) ~* '^[0-9a-f]{8}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{12}$'
    THEN current_setting('app.party_id', true)::uuid
    ELSE NULL
  END
$$;

CREATE OR REPLACE FUNCTION app.role() RETURNS text
LANGUAGE sql STABLE AS $$
  SELECT NULLIF(current_setting('app.role', true), '')
$$;

CREATE OR REPLACE FUNCTION app.is_staff() RETURNS boolean
LANGUAGE sql STABLE AS $$
  SELECT app.role() IN ('OWNER', 'FINANCE', 'PROJECT_MANAGER', 'SITE_ENGINEER', 'SALES', 'AUDITOR')
$$;

-- Reads project_assignments as the function owner so the policy on that table
-- cannot recurse. The owner must be the table owner, not siteledger_app.
CREATE OR REPLACE FUNCTION app.project_allowed(target_project uuid) RETURNS boolean
LANGUAGE sql STABLE SECURITY DEFINER SET search_path = public AS $$
  SELECT EXISTS (
    SELECT 1
    FROM project_assignments pa
    WHERE pa.project_id = target_project
      AND pa.user_id = app.user_id()
      AND pa.organization_id = app.organization_id()
      AND pa.deleted_at IS NULL
  )
$$;

CREATE OR REPLACE FUNCTION app.customer_booking_visible(target_booking uuid) RETURNS boolean
LANGUAGE sql STABLE SECURITY DEFINER SET search_path = public AS $$
  SELECT EXISTS (
    SELECT 1
    FROM bookings b
    JOIN booking_customers bc ON bc.booking_id = b.id
    WHERE b.id = target_booking
      AND b.organization_id = app.organization_id()
      AND bc.organization_id = app.organization_id()
      AND bc.party_id = app.party_id()
      AND bc.deleted_at IS NULL
      AND b.deleted_at IS NULL
  )
$$;

CREATE OR REPLACE FUNCTION app.vendor_invoice_visible(target_invoice uuid) RETURNS boolean
LANGUAGE sql STABLE SECURITY DEFINER SET search_path = public AS $$
  SELECT EXISTS (
    SELECT 1
    FROM vendor_invoices vi
    WHERE vi.id = target_invoice
      AND vi.organization_id = app.organization_id()
      AND vi.vendor_party_id = app.party_id()
  )
$$;

CREATE OR REPLACE FUNCTION app.payment_visible(target_payment uuid) RETURNS boolean
LANGUAGE sql STABLE SECURITY DEFINER SET search_path = public AS $$
  SELECT EXISTS (
    SELECT 1
    FROM payments p
    WHERE p.id = target_payment
      AND p.organization_id = app.organization_id()
      AND p.party_id = app.party_id()
  )
$$;

REVOKE ALL ON FUNCTION app.project_allowed(uuid) FROM PUBLIC;
REVOKE ALL ON FUNCTION app.customer_booking_visible(uuid) FROM PUBLIC;
REVOKE ALL ON FUNCTION app.vendor_invoice_visible(uuid) FROM PUBLIC;
REVOKE ALL ON FUNCTION app.payment_visible(uuid) FROM PUBLIC;
GRANT EXECUTE ON FUNCTION app.organization_id() TO siteledger_app;
GRANT EXECUTE ON FUNCTION app.user_id() TO siteledger_app;
GRANT EXECUTE ON FUNCTION app.party_id() TO siteledger_app;
GRANT EXECUTE ON FUNCTION app.role() TO siteledger_app;
GRANT EXECUTE ON FUNCTION app.is_staff() TO siteledger_app;
GRANT EXECUTE ON FUNCTION app.project_allowed(uuid) TO siteledger_app;
GRANT EXECUTE ON FUNCTION app.customer_booking_visible(uuid) TO siteledger_app;
GRANT EXECUTE ON FUNCTION app.vendor_invoice_visible(uuid) TO siteledger_app;
GRANT EXECUTE ON FUNCTION app.payment_visible(uuid) TO siteledger_app;

GRANT USAGE ON SCHEMA public, app TO siteledger_app;
GRANT SELECT, INSERT, UPDATE ON ALL TABLES IN SCHEMA public TO siteledger_app;
REVOKE DELETE ON ALL TABLES IN SCHEMA public FROM siteledger_app;
ALTER DEFAULT PRIVILEGES IN SCHEMA public
  GRANT SELECT, INSERT, UPDATE ON TABLES TO siteledger_app;

-- Tenant isolation for every table that has organization_id.
-- Global tables (users, auth_*, gst_rates, tds_sections) are skipped on purpose.
DO $$
DECLARE
  rec record;
BEGIN
  FOR rec IN
    SELECT c.table_name
    FROM information_schema.columns c
    JOIN information_schema.tables t
      ON t.table_schema = c.table_schema
     AND t.table_name = c.table_name
    WHERE c.table_schema = 'public'
      AND c.column_name = 'organization_id'
      AND t.table_type = 'BASE TABLE'
  LOOP
    EXECUTE format('ALTER TABLE %I ENABLE ROW LEVEL SECURITY', rec.table_name);
    EXECUTE format('DROP POLICY IF EXISTS tenant_isolation ON %I', rec.table_name);
    EXECUTE format(
      'CREATE POLICY tenant_isolation ON %I AS PERMISSIVE FOR ALL TO siteledger_app USING (organization_id = app.organization_id()) WITH CHECK (organization_id = app.organization_id())',
      rec.table_name
    );

    EXECUTE format('DROP POLICY IF EXISTS auditor_cannot_write ON %I', rec.table_name);
    EXECUTE format('DROP POLICY IF EXISTS auditor_cannot_update ON %I', rec.table_name);
    IF rec.table_name = 'audit_events' THEN
      EXECUTE format(
        'CREATE POLICY auditor_cannot_write ON %I AS RESTRICTIVE FOR INSERT TO siteledger_app WITH CHECK (app.role() IS NOT NULL)',
        rec.table_name
      );
      EXECUTE format(
        'CREATE POLICY auditor_cannot_update ON %I AS RESTRICTIVE FOR UPDATE TO siteledger_app USING (app.role() IS NOT NULL AND app.role() <> ''AUDITOR'') WITH CHECK (app.role() IS NOT NULL AND app.role() <> ''AUDITOR'')',
        rec.table_name
      );
    ELSE
      EXECUTE format(
        'CREATE POLICY auditor_cannot_write ON %I AS RESTRICTIVE FOR ALL TO siteledger_app USING (true) WITH CHECK (app.role() IS NOT NULL AND app.role() <> ''AUDITOR'')',
        rec.table_name
      );
    END IF;
  END LOOP;
END $$;

-- Project scope. A null project_id stays visible inside the firm (an unassigned
-- lead, for example). Portal roles pass this policy and are cut down below.
DO $$
DECLARE
  rec record;
BEGIN
  FOR rec IN
    SELECT c.table_name
    FROM information_schema.columns c
    JOIN information_schema.tables t
      ON t.table_schema = c.table_schema
     AND t.table_name = c.table_name
    WHERE c.table_schema = 'public'
      AND c.column_name = 'project_id'
      AND t.table_type = 'BASE TABLE'
  LOOP
    EXECUTE format('DROP POLICY IF EXISTS project_scope ON %I', rec.table_name);
    EXECUTE format($policy$
      CREATE POLICY project_scope ON %I AS RESTRICTIVE FOR ALL TO siteledger_app
      USING (
        project_id IS NULL
        OR app.role() IN ('OWNER', 'FINANCE', 'AUDITOR', 'VENDOR', 'CUSTOMER')
        OR (
          app.role() IN ('PROJECT_MANAGER', 'SITE_ENGINEER', 'SALES')
          AND app.project_allowed(project_id)
        )
      )
      WITH CHECK (
        project_id IS NULL
        OR app.role() IN ('OWNER', 'FINANCE', 'VENDOR', 'CUSTOMER')
        OR (
          app.role() IN ('PROJECT_MANAGER', 'SITE_ENGINEER', 'SALES')
          AND app.project_allowed(project_id)
        )
      )
    $policy$, rec.table_name);
  END LOOP;
END $$;

-- Staff-only tables: vendor and customer see nothing.
-- Portal tables are listed in the next section and are not in this loop.
DO $$
DECLARE
  rec record;
  portal text[] := ARRAY[
    'parties',
    'party_addresses',
    'party_bank_accounts',
    'party_contacts',
    'vendor_profiles',
    'purchase_orders',
    'purchase_order_lines',
    'vendor_invoices',
    'vendor_invoice_lines',
    'payments',
    'payment_allocations',
    'documents',
    'notifications',
    'bookings',
    'booking_customers',
    'agreements',
    'demand_notes',
    'demand_schedule_items',
    'receipts',
    'receipt_allocations',
    'customer_statements',
    'progress_updates',
    'units',
    'projects'
  ];
BEGIN
  FOR rec IN
    SELECT c.table_name
    FROM information_schema.columns c
    JOIN information_schema.tables t
      ON t.table_schema = c.table_schema
     AND t.table_name = c.table_name
    WHERE c.table_schema = 'public'
      AND c.column_name = 'organization_id'
      AND t.table_type = 'BASE TABLE'
      AND NOT (c.table_name = ANY (portal))
  LOOP
    EXECUTE format('DROP POLICY IF EXISTS staff_only ON %I', rec.table_name);
    EXECUTE format(
      'CREATE POLICY staff_only ON %I AS RESTRICTIVE FOR ALL TO siteledger_app USING (app.is_staff()) WITH CHECK (app.is_staff())',
      rec.table_name
    );
  END LOOP;
END $$;

-- Vendor and customer policies. Each one lets staff through and pins a portal
-- role to its own party. Customer writes are rejected. Vendor writes are
-- limited to invoices and documents.

CREATE OR REPLACE FUNCTION app.portal_read(own_row boolean) RETURNS boolean
LANGUAGE sql STABLE AS $$
  SELECT app.is_staff() OR (app.role() IN ('VENDOR', 'CUSTOMER') AND own_row)
$$;

DROP POLICY IF EXISTS portal_party ON parties;
CREATE POLICY portal_party ON parties AS RESTRICTIVE FOR ALL TO siteledger_app
  USING (app.portal_read(id = app.party_id()))
  WITH CHECK (app.is_staff());

DROP POLICY IF EXISTS portal_party ON party_addresses;
CREATE POLICY portal_party ON party_addresses AS RESTRICTIVE FOR ALL TO siteledger_app
  USING (app.portal_read(party_id = app.party_id()))
  WITH CHECK (app.is_staff());

DROP POLICY IF EXISTS portal_party ON party_bank_accounts;
CREATE POLICY portal_party ON party_bank_accounts AS RESTRICTIVE FOR ALL TO siteledger_app
  USING (app.portal_read(party_id = app.party_id()))
  WITH CHECK (app.is_staff());

DROP POLICY IF EXISTS portal_party ON party_contacts;
CREATE POLICY portal_party ON party_contacts AS RESTRICTIVE FOR ALL TO siteledger_app
  USING (app.portal_read(party_id = app.party_id()))
  WITH CHECK (app.is_staff());

DROP POLICY IF EXISTS portal_party ON vendor_profiles;
CREATE POLICY portal_party ON vendor_profiles AS RESTRICTIVE FOR ALL TO siteledger_app
  USING (app.is_staff() OR (app.role() = 'VENDOR' AND party_id = app.party_id()))
  WITH CHECK (app.is_staff());

DROP POLICY IF EXISTS portal_party ON purchase_orders;
CREATE POLICY portal_party ON purchase_orders AS RESTRICTIVE FOR ALL TO siteledger_app
  USING (app.is_staff() OR (app.role() = 'VENDOR' AND vendor_party_id = app.party_id()))
  WITH CHECK (app.is_staff());

DROP POLICY IF EXISTS portal_party ON purchase_order_lines;
CREATE POLICY portal_party ON purchase_order_lines AS RESTRICTIVE FOR ALL TO siteledger_app
  USING (
    app.is_staff()
    OR (
      app.role() = 'VENDOR'
      AND EXISTS (
        SELECT 1 FROM purchase_orders po
        WHERE po.id = purchase_order_lines.purchase_order_id
          AND po.vendor_party_id = app.party_id()
          AND po.organization_id = app.organization_id()
      )
    )
  )
  WITH CHECK (app.is_staff());

DROP POLICY IF EXISTS portal_party ON vendor_invoices;
CREATE POLICY portal_party ON vendor_invoices AS RESTRICTIVE FOR ALL TO siteledger_app
  USING (app.is_staff() OR (app.role() = 'VENDOR' AND vendor_party_id = app.party_id()))
  WITH CHECK (app.is_staff() OR (app.role() = 'VENDOR' AND vendor_party_id = app.party_id() AND source = 'VENDOR_PORTAL'));

DROP POLICY IF EXISTS portal_party ON vendor_invoice_lines;
CREATE POLICY portal_party ON vendor_invoice_lines AS RESTRICTIVE FOR ALL TO siteledger_app
  USING (app.is_staff() OR (app.role() = 'VENDOR' AND app.vendor_invoice_visible(invoice_id)))
  WITH CHECK (app.is_staff() OR (app.role() = 'VENDOR' AND app.vendor_invoice_visible(invoice_id)));

DROP POLICY IF EXISTS portal_party ON payments;
CREATE POLICY portal_party ON payments AS RESTRICTIVE FOR ALL TO siteledger_app
  USING (app.is_staff() OR (app.role() = 'VENDOR' AND party_id = app.party_id()))
  WITH CHECK (app.is_staff());

DROP POLICY IF EXISTS portal_party ON payment_allocations;
CREATE POLICY portal_party ON payment_allocations AS RESTRICTIVE FOR ALL TO siteledger_app
  USING (app.is_staff() OR (app.role() = 'VENDOR' AND app.payment_visible(payment_id)))
  WITH CHECK (app.is_staff());

DROP POLICY IF EXISTS portal_party ON notifications;
CREATE POLICY portal_party ON notifications AS RESTRICTIVE FOR ALL TO siteledger_app
  USING (app.is_staff() OR user_id = app.user_id())
  WITH CHECK (app.is_staff());

DROP POLICY IF EXISTS portal_party ON projects;
CREATE POLICY portal_party ON projects AS RESTRICTIVE FOR ALL TO siteledger_app
  USING (
    app.is_staff()
    OR (
      app.role() = 'CUSTOMER'
      AND EXISTS (
        SELECT 1
        FROM bookings b
        JOIN booking_customers bc ON bc.booking_id = b.id
        WHERE b.project_id = projects.id
          AND b.organization_id = app.organization_id()
          AND bc.party_id = app.party_id()
          AND bc.deleted_at IS NULL
      )
    )
    OR (
      app.role() = 'VENDOR'
      AND EXISTS (
        SELECT 1 FROM purchase_orders po
        WHERE po.project_id = projects.id
          AND po.organization_id = app.organization_id()
          AND po.vendor_party_id = app.party_id()
      )
    )
  )
  WITH CHECK (app.is_staff());

DROP POLICY IF EXISTS portal_party ON units;
CREATE POLICY portal_party ON units AS RESTRICTIVE FOR ALL TO siteledger_app
  USING (
    app.is_staff()
    OR (
      app.role() = 'CUSTOMER'
      AND EXISTS (
        SELECT 1
        FROM bookings b
        JOIN booking_customers bc ON bc.booking_id = b.id
        WHERE b.unit_id = units.id
          AND bc.party_id = app.party_id()
          AND bc.deleted_at IS NULL
          AND b.deleted_at IS NULL
      )
    )
  )
  WITH CHECK (app.is_staff());

DROP POLICY IF EXISTS portal_party ON bookings;
CREATE POLICY portal_party ON bookings AS RESTRICTIVE FOR ALL TO siteledger_app
  USING (app.is_staff() OR (app.role() = 'CUSTOMER' AND app.customer_booking_visible(id)))
  WITH CHECK (app.is_staff());

DROP POLICY IF EXISTS portal_party ON booking_customers;
CREATE POLICY portal_party ON booking_customers AS RESTRICTIVE FOR ALL TO siteledger_app
  USING (app.is_staff() OR (app.role() = 'CUSTOMER' AND party_id = app.party_id()))
  WITH CHECK (app.is_staff());

DROP POLICY IF EXISTS portal_party ON agreements;
CREATE POLICY portal_party ON agreements AS RESTRICTIVE FOR ALL TO siteledger_app
  USING (app.is_staff() OR (app.role() = 'CUSTOMER' AND app.customer_booking_visible(booking_id)))
  WITH CHECK (app.is_staff());

DROP POLICY IF EXISTS portal_party ON demand_notes;
CREATE POLICY portal_party ON demand_notes AS RESTRICTIVE FOR ALL TO siteledger_app
  USING (app.is_staff() OR (app.role() = 'CUSTOMER' AND app.customer_booking_visible(booking_id)))
  WITH CHECK (app.is_staff());

DROP POLICY IF EXISTS portal_party ON demand_schedule_items;
CREATE POLICY portal_party ON demand_schedule_items AS RESTRICTIVE FOR ALL TO siteledger_app
  USING (app.is_staff() OR (app.role() = 'CUSTOMER' AND app.customer_booking_visible(booking_id)))
  WITH CHECK (app.is_staff());

DROP POLICY IF EXISTS portal_party ON receipts;
CREATE POLICY portal_party ON receipts AS RESTRICTIVE FOR ALL TO siteledger_app
  USING (app.is_staff() OR (app.role() = 'CUSTOMER' AND app.customer_booking_visible(booking_id)))
  WITH CHECK (app.is_staff());

DROP POLICY IF EXISTS portal_party ON receipt_allocations;
CREATE POLICY portal_party ON receipt_allocations AS RESTRICTIVE FOR ALL TO siteledger_app
  USING (
    app.is_staff()
    OR (
      app.role() = 'CUSTOMER'
      AND EXISTS (
        SELECT 1 FROM receipts r
        WHERE r.id = receipt_allocations.receipt_id
          AND app.customer_booking_visible(r.booking_id)
      )
    )
  )
  WITH CHECK (app.is_staff());

DROP POLICY IF EXISTS portal_party ON customer_statements;
CREATE POLICY portal_party ON customer_statements AS RESTRICTIVE FOR ALL TO siteledger_app
  USING (app.is_staff() OR (app.role() = 'CUSTOMER' AND app.customer_booking_visible(booking_id)))
  WITH CHECK (app.is_staff());

DROP POLICY IF EXISTS portal_party ON progress_updates;
CREATE POLICY portal_party ON progress_updates AS RESTRICTIVE FOR ALL TO siteledger_app
  USING (
    app.is_staff()
    OR (
      app.role() = 'CUSTOMER'
      AND published_to_customers
      AND EXISTS (
        SELECT 1
        FROM bookings b
        JOIN booking_customers bc ON bc.booking_id = b.id
        WHERE b.project_id = progress_updates.project_id
          AND b.organization_id = app.organization_id()
          AND bc.party_id = app.party_id()
          AND bc.deleted_at IS NULL
          AND b.status NOT IN ('CANCELLED', 'TRANSFERRED')
      )
    )
  )
  WITH CHECK (app.is_staff());

-- Documents are polymorphic. Staff see the firm's files. A customer sees files
-- hung on their booking chain. A vendor sees files hung on their invoices,
-- purchase orders, and payments. Uploads are allowed for staff and vendors.
DROP POLICY IF EXISTS portal_party ON documents;
CREATE POLICY portal_party ON documents AS RESTRICTIVE FOR ALL TO siteledger_app
  USING (
    app.is_staff()
    OR (
      app.role() = 'VENDOR'
      AND (
        (entity_type = 'VENDOR_INVOICE' AND app.vendor_invoice_visible(entity_id))
        OR (entity_type = 'PAYMENT' AND app.payment_visible(entity_id))
        OR (
          entity_type = 'PURCHASE_ORDER'
          AND EXISTS (
            SELECT 1 FROM purchase_orders po
            WHERE po.id = documents.entity_id
              AND po.vendor_party_id = app.party_id()
              AND po.organization_id = app.organization_id()
          )
        )
      )
    )
    OR (
      app.role() = 'CUSTOMER'
      AND (
        (entity_type = 'BOOKING' AND app.customer_booking_visible(entity_id))
        OR (
          entity_type = 'AGREEMENT'
          AND EXISTS (
            SELECT 1 FROM agreements a
            WHERE a.id = documents.entity_id
              AND app.customer_booking_visible(a.booking_id)
          )
        )
        OR (
          entity_type = 'DEMAND_NOTE'
          AND EXISTS (
            SELECT 1 FROM demand_notes d
            WHERE d.id = documents.entity_id
              AND app.customer_booking_visible(d.booking_id)
          )
        )
        OR (
          entity_type = 'RECEIPT'
          AND EXISTS (
            SELECT 1 FROM receipts r
            WHERE r.id = documents.entity_id
              AND app.customer_booking_visible(r.booking_id)
          )
        )
        OR (
          entity_type = 'CUSTOMER_STATEMENT'
          AND EXISTS (
            SELECT 1 FROM customer_statements cs
            WHERE cs.id = documents.entity_id
              AND app.customer_booking_visible(cs.booking_id)
          )
        )
        OR (
          entity_type = 'PROGRESS_UPDATE'
          AND EXISTS (
            SELECT 1 FROM progress_updates pu
            WHERE pu.id = documents.entity_id
              AND pu.published_to_customers
              AND pu.organization_id = app.organization_id()
              AND EXISTS (
                SELECT 1
                FROM bookings b
                JOIN booking_customers bc ON bc.booking_id = b.id
                WHERE b.project_id = pu.project_id
                  AND bc.party_id = app.party_id()
                  AND bc.deleted_at IS NULL
                  AND b.status NOT IN ('CANCELLED', 'TRANSFERRED')
              )
          )
        )
      )
    )
  )
  WITH CHECK (
    app.is_staff()
    OR (app.role() = 'VENDOR' AND entity_type = 'VENDOR_INVOICE')
  );

GRANT EXECUTE ON FUNCTION app.portal_read(boolean) TO siteledger_app;
-- prisma/sql/immutability.sql
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
-- prisma/sql/checks.sql
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
-- prisma/sql/views.sql
-- Reporting views. Not applied in step 1.
-- security_invoker is required. Without it the view owner bypasses RLS and
-- a tenant could read another firm's cash book. PostgreSQL 16.

CREATE OR REPLACE VIEW cash_book_lines
WITH (security_invoker = true) AS
SELECT
  jl.organization_id,
  jl.id AS journal_line_id,
  je.id AS journal_entry_id,
  je.entry_date,
  je.entry_number,
  je.status,
  je.narration AS entry_narration,
  ba.id AS bank_account_id,
  ba.display_name AS bank_account_name,
  ba.is_cash,
  jl.debit_paise,
  jl.credit_paise,
  (jl.debit_paise - jl.credit_paise) AS signed_paise
FROM journal_lines jl
JOIN journal_entries je ON je.id = jl.entry_id
JOIN bank_accounts ba ON ba.gl_account_id = jl.gl_account_id
WHERE je.status IN ('POSTED', 'REVERSED')
  AND je.deleted_at IS NULL
  AND ba.deleted_at IS NULL;

COMMENT ON VIEW cash_book_lines IS
  'Posted and reversed journal lines on a bank or cash account. Reversed rows stay, so the original and its reversal both remain visible.';

CREATE OR REPLACE VIEW money_trail
WITH (security_invoker = true) AS
SELECT
  jl.organization_id,
  jl.id AS journal_line_id,
  je.id AS journal_entry_id,
  je.entry_date,
  je.entry_number,
  je.status,
  je.source,
  je.source_id,
  je.narration,
  gl.code AS gl_code,
  gl.name AS gl_name,
  gl.account_type,
  jl.debit_paise,
  jl.credit_paise,
  jl.project_id,
  jl.cost_centre_id,
  jl.unit_id,
  jl.party_id
FROM journal_lines jl
JOIN journal_entries je ON je.id = jl.entry_id
JOIN gl_accounts gl ON gl.id = jl.gl_account_id
WHERE je.status IN ('POSTED', 'REVERSED')
  AND je.deleted_at IS NULL;

COMMENT ON VIEW money_trail IS
  'Every posted or reversed journal line, with the unit, party, and project it touches. Documents hang off the source row, not off this view.';

-- Cost area for one unit. Built if it is above zero, else approved, else planned.
CREATE OR REPLACE VIEW unit_cost_area
WITH (security_invoker = true) AS
SELECT
  u.organization_id,
  u.project_id,
  u.id AS unit_id,
  p.cost_area_basis,
  CASE p.cost_area_basis
    WHEN 'CARPET' THEN
      CASE
        WHEN u.carpet_built_sqft > 0 THEN u.carpet_built_sqft
        WHEN u.carpet_approved_sqft > 0 THEN u.carpet_approved_sqft
        ELSE u.carpet_planned_sqft
      END
    WHEN 'BUILT_UP' THEN
      CASE
        WHEN u.built_up_built_sqft > 0 THEN u.built_up_built_sqft
        WHEN u.built_up_approved_sqft > 0 THEN u.built_up_approved_sqft
        ELSE u.built_up_planned_sqft
      END
    ELSE
      CASE
        WHEN u.super_built_up_built_sqft > 0 THEN u.super_built_up_built_sqft
        WHEN u.super_built_up_approved_sqft > 0 THEN u.super_built_up_approved_sqft
        ELSE u.super_built_up_planned_sqft
      END
  END AS cost_area_sqft
FROM units u
JOIN projects p ON p.id = u.project_id
WHERE u.deleted_at IS NULL
  AND p.deleted_at IS NULL;

CREATE OR REPLACE VIEW project_area
WITH (security_invoker = true) AS
SELECT
  organization_id,
  project_id,
  COALESCE(SUM(cost_area_sqft), 0) AS cost_area_sqft
FROM unit_cost_area
GROUP BY organization_id, project_id;

-- Commercial margin: agreement base of live bookings, minus project expense.
-- A zero area yields a null cost per sqft rather than a fake zero.
CREATE OR REPLACE VIEW project_commercial_margin
WITH (security_invoker = true) AS
WITH sales AS (
  SELECT
    b.organization_id,
    b.project_id,
    COALESCE(SUM(b.base_value_paise), 0) AS agreement_base_paise
  FROM bookings b
  WHERE b.deleted_at IS NULL
    AND b.status NOT IN ('CANCELLED', 'TRANSFERRED')
  GROUP BY b.organization_id, b.project_id
),
expense AS (
  SELECT
    jl.organization_id,
    jl.project_id,
    COALESCE(SUM(jl.debit_paise - jl.credit_paise), 0) AS expense_paise
  FROM journal_lines jl
  JOIN journal_entries je ON je.id = jl.entry_id
  JOIN gl_accounts gl ON gl.id = jl.gl_account_id
  WHERE je.status IN ('POSTED', 'REVERSED')
    AND je.deleted_at IS NULL
    AND gl.account_type = 'EXPENSE'
    AND jl.project_id IS NOT NULL
  GROUP BY jl.organization_id, jl.project_id
)
SELECT
  p.organization_id,
  p.id AS project_id,
  p.name AS project_name,
  COALESCE(sales.agreement_base_paise, 0) AS agreement_base_paise,
  COALESCE(expense.expense_paise, 0) AS expense_paise,
  COALESCE(sales.agreement_base_paise, 0) - COALESCE(expense.expense_paise, 0) AS commercial_margin_paise,
  area.cost_area_sqft,
  CASE
    WHEN area.cost_area_sqft IS NULL OR area.cost_area_sqft = 0 THEN NULL
    ELSE (COALESCE(expense.expense_paise, 0)::numeric / 100) / area.cost_area_sqft
  END AS cost_rupees_per_sqft
FROM projects p
LEFT JOIN sales
  ON sales.project_id = p.id
 AND sales.organization_id = p.organization_id
LEFT JOIN expense
  ON expense.project_id = p.id
 AND expense.organization_id = p.organization_id
LEFT JOIN project_area area
  ON area.project_id = p.id
 AND area.organization_id = p.organization_id
WHERE p.deleted_at IS NULL;

COMMENT ON VIEW project_commercial_margin IS
  'Agreement value minus project expense. This is not accounting profit.';

-- Accounting result from posted and reversed income and expense lines.
CREATE OR REPLACE VIEW project_accounting_result
WITH (security_invoker = true) AS
SELECT
  jl.organization_id,
  jl.project_id,
  COALESCE(SUM(
    CASE
      WHEN gl.account_type = 'INCOME' THEN jl.credit_paise - jl.debit_paise
      ELSE 0
    END
  ), 0) AS income_paise,
  COALESCE(SUM(
    CASE
      WHEN gl.account_type = 'EXPENSE' THEN jl.debit_paise - jl.credit_paise
      ELSE 0
    END
  ), 0) AS expense_paise,
  COALESCE(SUM(
    CASE
      WHEN gl.account_type = 'INCOME' THEN jl.credit_paise - jl.debit_paise
      WHEN gl.account_type = 'EXPENSE' THEN jl.credit_paise - jl.debit_paise
      ELSE 0
    END
  ), 0) AS accounting_profit_paise
FROM journal_lines jl
JOIN journal_entries je ON je.id = jl.entry_id
JOIN gl_accounts gl ON gl.id = jl.gl_account_id
WHERE je.status IN ('POSTED', 'REVERSED')
  AND je.deleted_at IS NULL
  AND jl.project_id IS NOT NULL
  AND gl.account_type IN ('INCOME', 'EXPENSE')
GROUP BY jl.organization_id, jl.project_id;

COMMENT ON VIEW project_accounting_result IS
  'Posted income minus posted expense. Customer receipts sit in advances until possession, so this profit lags the commercial margin.';
-- prisma/sql/chain.sql
-- Step 3. The local app role logs in with the placeholder password from .env.example.
-- Chain moves go through security-definer functions so an auditor can append an
-- export to the audit chain without a general permission to update chain_heads.
-- Run after prisma/sql/rls.sql, immutability.sql, checks.sql, and views.sql.

ALTER ROLE siteledger_app WITH LOGIN PASSWORD 'siteledger_app';

GRANT SELECT ON
  cash_book_lines,
  money_trail,
  unit_cost_area,
  project_area,
  project_commercial_margin,
  project_accounting_result
TO siteledger_app;

CREATE OR REPLACE FUNCTION app.lock_chain_head(p_organization_id uuid, p_chain text)
RETURNS TABLE(last_hash text, last_sequence integer)
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = public
AS $$
BEGIN
  IF p_organization_id IS DISTINCT FROM app.organization_id() THEN
    RAISE EXCEPTION 'chain head is outside this firm';
  END IF;
  IF app.role() IS NULL THEN
    RAISE EXCEPTION 'a role is required';
  END IF;
  IF app.role() = 'AUDITOR' AND p_chain <> 'AUDIT' THEN
    RAISE EXCEPTION 'an auditor cannot move this chain';
  END IF;

  RETURN QUERY
  SELECT c.last_hash, c.last_sequence
  FROM chain_heads c
  WHERE c.organization_id = p_organization_id
    AND c.chain = p_chain::"ChainName"
  FOR UPDATE;
END;
$$;

CREATE OR REPLACE FUNCTION app.advance_chain_head(
  p_organization_id uuid,
  p_chain text,
  p_last_hash text,
  p_last_sequence integer
) RETURNS void
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = public
AS $$
BEGIN
  IF p_organization_id IS DISTINCT FROM app.organization_id() THEN
    RAISE EXCEPTION 'chain head is outside this firm';
  END IF;
  IF app.role() IS NULL THEN
    RAISE EXCEPTION 'a role is required';
  END IF;
  IF app.role() = 'AUDITOR' AND p_chain <> 'AUDIT' THEN
    RAISE EXCEPTION 'an auditor cannot move this chain';
  END IF;
  IF p_last_hash !~ '^[0-9a-f]{64}$' THEN
    RAISE EXCEPTION 'chain hash must be 64 lowercase hex characters';
  END IF;

  UPDATE chain_heads
  SET last_hash = p_last_hash,
      last_sequence = p_last_sequence,
      updated_at = NOW()
  WHERE organization_id = p_organization_id
    AND chain = p_chain::"ChainName";

  IF NOT FOUND THEN
    RAISE EXCEPTION 'chain head missing';
  END IF;
END;
$$;

REVOKE ALL ON FUNCTION app.lock_chain_head(uuid, text) FROM PUBLIC;
REVOKE ALL ON FUNCTION app.advance_chain_head(uuid, text, text, integer) FROM PUBLIC;
GRANT EXECUTE ON FUNCTION app.lock_chain_head(uuid, text) TO siteledger_app;
GRANT EXECUTE ON FUNCTION app.advance_chain_head(uuid, text, text, integer) TO siteledger_app;
