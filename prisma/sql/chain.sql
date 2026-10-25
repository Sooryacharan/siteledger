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
