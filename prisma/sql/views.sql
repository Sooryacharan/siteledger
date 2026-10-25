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
