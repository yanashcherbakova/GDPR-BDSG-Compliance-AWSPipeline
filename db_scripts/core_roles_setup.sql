DO $do$
BEGIN
  IF NOT EXISTS (SELECT 1 FROM pg_roles WHERE rolname='app_owner') THEN EXECUTE 'CREATE ROLE app_owner NOLOGIN'; END IF;
  IF NOT EXISTS (SELECT 1 FROM pg_roles WHERE rolname='app_admin') THEN EXECUTE 'CREATE ROLE app_admin NOLOGIN'; END IF;
  IF NOT EXISTS (SELECT 1 FROM pg_roles WHERE rolname='app_read') THEN EXECUTE 'CREATE ROLE app_read NOLOGIN'; END IF;
  IF NOT EXISTS (SELECT 1 FROM pg_roles WHERE rolname='app_write') THEN EXECUTE 'CREATE ROLE app_write NOLOGIN'; END IF;
  IF NOT EXISTS (SELECT 1 FROM pg_roles WHERE rolname='app_hr') THEN EXECUTE 'CREATE ROLE app_hr NOLOGIN'; END IF;
  IF NOT EXISTS (SELECT 1 FROM pg_roles WHERE rolname='app_accountant') THEN EXECUTE 'CREATE ROLE app_accountant NOLOGIN'; END IF;
  IF NOT EXISTS (SELECT 1 FROM pg_roles WHERE rolname='app_manager') THEN EXECUTE 'CREATE ROLE app_manager NOLOGIN'; END IF;
  IF NOT EXISTS (SELECT 1 FROM pg_roles WHERE rolname='app_medical') THEN EXECUTE 'CREATE ROLE app_medical NOLOGIN'; END IF;
  IF NOT EXISTS (SELECT 1 FROM pg_roles WHERE rolname='app_analyst') THEN EXECUTE 'CREATE ROLE app_analyst NOLOGIN'; END IF;
  IF NOT EXISTS (SELECT 1 FROM pg_roles WHERE rolname='app_dpo') THEN EXECUTE 'CREATE ROLE app_dpo NOLOGIN'; END IF;
  IF NOT EXISTS (SELECT 1 FROM pg_roles WHERE rolname='app_system') THEN EXECUTE 'CREATE ROLE app_system NOLOGIN'; END IF;
END
$do$ LANGUAGE plpgsql;

DO $do$
BEGIN
  EXECUTE format('REVOKE CREATE ON DATABASE %I FROM PUBLIC', current_database());
END
$do$ LANGUAGE plpgsql;

REVOKE ALL ON SCHEMA company FROM PUBLIC;
REVOKE ALL ON SCHEMA finance FROM PUBLIC;
REVOKE ALL ON SCHEMA events FROM PUBLIC;

ALTER SCHEMA company OWNER TO app_owner;
ALTER SCHEMA finance OWNER TO app_owner;
ALTER SCHEMA events OWNER TO app_owner;

GRANT USAGE ON SCHEMA company, finance, events TO
  app_read, app_write, app_admin,
  app_hr, app_accountant, app_manager, app_medical, app_analyst, app_dpo, app_system;

GRANT app_read  TO app_hr, app_accountant, app_manager, app_medical, app_analyst, app_dpo;
GRANT app_admin TO app_system;