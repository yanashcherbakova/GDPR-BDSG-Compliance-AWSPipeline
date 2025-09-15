ALTER DEFAULT PRIVILEGES IN SCHEMA finance REVOKE ALL ON TABLES FROM PUBLIC;
ALTER DEFAULT PRIVILEGES IN SCHEMA finance REVOKE ALL ON SEQUENCES FROM PUBLIC;

REVOKE ALL ON finance.employee_compensation FROM PUBLIC;
GRANT SELECT, INSERT, UPDATE, DELETE ON finance.employee_compensation
  TO app_accountant, app_dpo, app_system;

GRANT USAGE, SELECT ON ALL SEQUENCES IN SCHEMA finance TO app_accountant, app_dpo, app_system;

GRANT SELECT ON finance.salary_bands TO app_accountant, app_analyst, app_manager, app_dpo;

REVOKE ALL ON finance.payment_details_ref FROM PUBLIC;
GRANT SELECT ON finance.payment_details_ref TO app_accountant, app_dpo, app_system;

DROP VIEW IF EXISTS finance.v_employee_compensation_masked;
CREATE VIEW finance.v_employee_compensation_masked
WITH (security_barrier = true) AS
SELECT
  c.comp_id,
  c.employee_id,
  c.band_id,
  NULL::numeric(12,2) AS base_salary_amount,
  c.currency,
  c.effective_from,
  c.effective_to,
  c.created_at, c.updated_at
FROM finance.employee_compensation c;
ALTER VIEW finance.v_employee_compensation_masked OWNER TO app_owner;

GRANT SELECT ON finance.v_employee_compensation_masked
  TO app_hr, app_manager, app_analyst;

ALTER TABLE finance.employee_compensation ENABLE ROW LEVEL SECURITY;


DO $do$
BEGIN
  IF NOT EXISTS (
    SELECT 1 FROM pg_policies
    WHERE schemaname='finance' AND tablename='employee_compensation' AND policyname='comp_full_access'
  ) THEN
    EXECUTE $sql$
      CREATE POLICY comp_full_access
      ON finance.employee_compensation
      USING (
        pg_has_role(current_user, 'app_accountant', 'member')
        OR pg_has_role(current_user, 'app_dpo', 'member')
        OR pg_has_role(current_user, 'app_system', 'member')
      )
      WITH CHECK (
        pg_has_role(current_user, 'app_accountant', 'member')
        OR pg_has_role(current_user, 'app_dpo', 'member')
        OR pg_has_role(current_user, 'app_system', 'member')
      )
    $sql$;
  END IF;
END
$do$ LANGUAGE plpgsql;

GRANT INSERT ON finance.payment_details_ref TO app_system;
ALTER TABLE finance.payment_details_ref ENABLE ROW LEVEL SECURITY;

DO $do$
BEGIN
  IF NOT EXISTS (
    SELECT 1 FROM pg_policies
    WHERE schemaname='finance' AND tablename='payment_details_ref' AND policyname='pdr_select_roles'
  ) THEN
    EXECUTE $sql$
      CREATE POLICY pdr_select_roles
      ON finance.payment_details_ref
      FOR SELECT
      USING (
        pg_has_role(current_user, 'app_accountant', 'member')
        OR pg_has_role(current_user, 'app_dpo', 'member')
        OR pg_has_role(current_user, 'app_system', 'member')
      )
    $sql$;
  END IF;

  IF NOT EXISTS (
    SELECT 1 FROM pg_policies
    WHERE schemaname='finance' AND tablename='payment_details_ref' AND policyname='pdr_insert_system'
  ) THEN
    EXECUTE $sql$
      CREATE POLICY pdr_insert_system
      ON finance.payment_details_ref
      FOR INSERT
      WITH CHECK (pg_has_role(current_user, 'app_system', 'member'))
    $sql$;
  END IF;
END
$do$ LANGUAGE plpgsql;