DO $$
BEGIN
  -- HR
  IF NOT EXISTS (SELECT 1 FROM pg_roles WHERE rolname = 'u_hr') THEN
    CREATE ROLE u_hr
      LOGIN INHERIT
      NOSUPERUSER NOCREATEDB NOCREATEROLE NOREPLICATION
      PASSWORD '16102024hr&q9';
    GRANT app_hr TO u_hr;
  END IF;

  -- Accountant
  IF NOT EXISTS (SELECT 1 FROM pg_roles WHERE rolname = 'u_accountant') THEN
    CREATE ROLE u_accountant
      LOGIN INHERIT
      NOSUPERUSER NOCREATEDB NOCREATEROLE NOREPLICATION
      PASSWORD '09022025ac&m2';
    GRANT app_accountant TO u_accountant;
  END IF;

  -- Manager
  IF NOT EXISTS (SELECT 1 FROM pg_roles WHERE rolname = 'u_manager') THEN
    CREATE ROLE u_manager
      LOGIN INHERIT
      NOSUPERUSER NOCREATEDB NOCREATEROLE NOREPLICATION
      PASSWORD '07052025ma&d4';
    GRANT app_manager TO u_manager;
  END IF;

  -- Medical
  IF NOT EXISTS (SELECT 1 FROM pg_roles WHERE rolname = 'u_medical') THEN
    CREATE ROLE u_medical
      LOGIN INHERIT
      NOSUPERUSER NOCREATEDB NOCREATEROLE NOREPLICATION
      PASSWORD '18112025me&d3';
    GRANT app_medical TO u_medical;
  END IF;

  -- Analyst
  IF NOT EXISTS (SELECT 1 FROM pg_roles WHERE rolname = 'u_analyst') THEN
    CREATE ROLE u_analyst
      LOGIN INHERIT
      NOSUPERUSER NOCREATEDB NOCREATEROLE NOREPLICATION
      PASSWORD '01012026an&y8';
    GRANT app_analyst TO u_analyst;
  END IF;

  -- DPO
  IF NOT EXISTS (SELECT 1 FROM pg_roles WHERE rolname = 'u_dpo') THEN
    CREATE ROLE u_dpo
      LOGIN INHERIT
      NOSUPERUSER NOCREATEDB NOCREATEROLE NOREPLICATION
      PASSWORD '10032026dp&o9';
    GRANT app_dpo TO u_dpo;
  END IF;

  -- System / service
  IF NOT EXISTS (SELECT 1 FROM pg_roles WHERE rolname = 'u_system') THEN
    CREATE ROLE u_system
      LOGIN INHERIT
      NOSUPERUSER NOCREATEDB NOCREATEROLE NOREPLICATION
      PASSWORD '13042026sy&s1';
    GRANT app_system TO u_system;
  END IF;
END $$;