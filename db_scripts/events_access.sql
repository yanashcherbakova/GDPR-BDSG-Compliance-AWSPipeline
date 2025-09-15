REVOKE ALL ON events.audit_events FROM PUBLIC;
GRANT SELECT ON events.audit_events TO app_dpo, app_admin;
GRANT INSERT ON events.audit_events TO app_system;

REVOKE ALL ON events.external_artifacts FROM PUBLIC;
GRANT SELECT ON events.external_artifacts TO app_dpo, app_admin, app_accountant;
GRANT INSERT ON events.external_artifacts TO app_system;

ALTER DEFAULT PRIVILEGES IN SCHEMA events
  GRANT SELECT ON TABLES TO app_dpo, app_admin;

ALTER TABLE events.audit_events ENABLE ROW LEVEL SECURITY;
ALTER TABLE events.external_artifacts ENABLE ROW LEVEL SECURITY;

DO $do$
BEGIN
  IF NOT EXISTS (
    SELECT 1 FROM pg_policies
    WHERE schemaname='events' AND tablename='audit_events' AND policyname='ae_select_dpo_admin'
  ) THEN
    EXECUTE $sql$
      CREATE POLICY ae_select_dpo_admin
      ON events.audit_events
      FOR SELECT
      USING (
        pg_has_role(current_user, 'app_dpo', 'member')
        OR pg_has_role(current_user, 'app_admin', 'member')
      )
    $sql$;
  END IF;

  IF NOT EXISTS (
    SELECT 1 FROM pg_policies
    WHERE schemaname='events' AND tablename='audit_events' AND policyname='ae_insert_system'
  ) THEN
    EXECUTE $sql$
      CREATE POLICY ae_insert_system
      ON events.audit_events
      FOR INSERT
      WITH CHECK (pg_has_role(current_user, 'app_system', 'member'))
    $sql$;
  END IF;
END
$do$ LANGUAGE plpgsql;

DO $do$
BEGIN
  IF NOT EXISTS (
    SELECT 1 FROM pg_policies
    WHERE schemaname='events' AND tablename='external_artifacts' AND policyname='ea_select_roles'
  ) THEN
    EXECUTE $sql$
      CREATE POLICY ea_select_roles
      ON events.external_artifacts
      FOR SELECT
      USING (
        pg_has_role(current_user, 'app_dpo', 'member')
        OR pg_has_role(current_user, 'app_admin', 'member')
        OR pg_has_role(current_user, 'app_accountant', 'member')
      )
    $sql$;
  END IF;

  IF NOT EXISTS (
    SELECT 1 FROM pg_policies
    WHERE schemaname='events' AND tablename='external_artifacts' AND policyname='ea_insert_system'
  ) THEN
    EXECUTE $sql$
      CREATE POLICY ea_insert_system
      ON events.external_artifacts
      FOR INSERT
      WITH CHECK (pg_has_role(current_user, 'app_system', 'member'))
    $sql$;
  END IF;
END
$do$ LANGUAGE plpgsql;