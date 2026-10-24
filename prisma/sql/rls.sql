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
