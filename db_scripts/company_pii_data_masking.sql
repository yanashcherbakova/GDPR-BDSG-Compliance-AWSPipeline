GRANT SELECT ON ALL TABLES IN SCHEMA company TO app_read;
GRANT SELECT ON ALL SEQUENCES IN SCHEMA company TO app_read;

ALTER DEFAULT PRIVILEGES IN SCHEMA company
  GRANT SELECT ON TABLES TO app_read;

REVOKE ALL ON company.employees FROM PUBLIC;
GRANT SELECT, INSERT, UPDATE, DELETE ON company.employees TO app_dpo, app_system;

DROP VIEW IF EXISTS company.v_employees_masked;
CREATE VIEW company.v_employees_masked
WITH (security_barrier = true) AS
SELECT
  e.employee_id,
  e.employee_no,
  e.first_name,
  e.last_name,
  to_char(e.date_of_birth, 'YYYY-"**"-"**"') AS date_of_birth_masked,
  regexp_replace(e.email_work, '(^.).*(@.*$)', '\1***\2') AS email_work_masked,
  CASE WHEN e.phone_work IS NULL THEN NULL
       ELSE '***-***-' || right(e.phone_work, 2) END AS phone_work_masked,
  e.hire_date,
  e.termination_date,
  e.current_department_id,
  e.current_position_id,
  e.is_manager,
  e.country,
  e.lawful_basis,
  e.created_at, e.updated_at, e.deleted_at
FROM company.employees e;

GRANT SELECT ON company.v_employees_masked
  TO app_hr, app_manager, app_accountant, app_analyst;

GRANT SELECT ON company.departments, company.positions TO app_read;

REVOKE SELECT ON company.employees
  FROM app_read, app_hr, app_manager, app_accountant, app_analyst;

ALTER TABLE company.employees ENABLE ROW LEVEL SECURITY;

DO $do$
BEGIN
  IF NOT EXISTS (
    SELECT 1 FROM pg_policies
    WHERE schemaname='company' AND tablename='employees' AND policyname='emp_full_access'
  ) THEN
    EXECUTE $sql$
      CREATE POLICY emp_full_access
      ON company.employees
      USING (
        pg_has_role(current_user, 'app_dpo', 'member')
        OR pg_has_role(current_user, 'app_system', 'member')
      )
      WITH CHECK (
        pg_has_role(current_user, 'app_dpo', 'member')
        OR pg_has_role(current_user, 'app_system', 'member')
      );
    $sql$;
  END IF;
END
$do$ LANGUAGE plpgsql;

DO $do$
BEGIN
  IF NOT EXISTS (
    SELECT 1 FROM pg_policies
    WHERE schemaname='company' AND tablename='employees' AND policyname='emp_by_dept_hr_mgr'
  ) THEN
    EXECUTE $sql$
      CREATE POLICY emp_by_dept_hr_mgr
      ON company.employees
      USING (
        (pg_has_role(current_user, 'app_hr', 'member')
         OR pg_has_role(current_user, 'app_manager', 'member'))
        AND current_setting('app.dept_id', true) IS NOT NULL
        AND current_department_id::text = current_setting('app.dept_id', true)
      )
      WITH CHECK (
        (pg_has_role(current_user, 'app_hr', 'member')
         OR pg_has_role(current_user, 'app_manager', 'member'))
        AND current_setting('app.dept_id', true) IS NOT NULL
        AND current_department_id::text = current_setting('app.dept_id', true)
      );
    $sql$;
  END IF;
END
$do$ LANGUAGE plpgsql;

DO $do$
BEGIN
  IF NOT EXISTS (
    SELECT 1 FROM pg_policies
    WHERE schemaname='company' AND tablename='employees' AND policyname='emp_read_analyst_by_dept'
  ) THEN
    EXECUTE $sql$
      CREATE POLICY emp_read_analyst_by_dept
      ON company.employees
      FOR SELECT
      USING (
        pg_has_role(current_user, 'app_analyst', 'member')
        AND current_setting('app.dept_id', true) IS NOT NULL
        AND current_department_id::text = current_setting('app.dept_id', true)
      );
    $sql$;
  END IF;
END
$do$ LANGUAGE plpgsql;
