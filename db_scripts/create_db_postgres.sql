CREATE EXTENSION IF NOT EXISTS "pgcrypto"; -- pgcrypto: gen_random_uuid() to generate UUID


CREATE SCHEMA IF NOT EXISTS company;
CREATE SCHEMA IF NOT EXISTS finance;
CREATE SCHEMA IF NOT EXISTS events;


--Company ENUM types creation
--We define a custom ENUM type for user roles
--Thanks to the IF NOT EXISTS check, this block can be safely re-run without breaking the database structure
DO $$
BEGIN
    IF NOT EXISTS (
        SELECT 1
        FROM pg_type t
        JOIN pg_namespace n ON n.oid = t.typnamespace
        WHERE t.typname = 'user_role' AND n.nspname = 'company'
    ) THEN
        CREATE TYPE company.user_role AS ENUM (
            'HR', 'Accountant', 'Manager', 'MedicalConsultant', 'Analyst', 'DPO', 'System'
        );
    END IF;
END $$;

--SCHEMA: COMPANY
CREATE TABLE company.departments (
    department_id   UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    code            TEXT UNIQUE NOT NULL,
    name            TEXT NOT NULL,
    created_at      TIMESTAMPTZ NOT NULL DEFAULT now(),
    updated_at      TIMESTAMPTZ NOT NULL DEFAULT now(),
    deleted_at      TIMESTAMPTZ
);

CREATE TABLE company.positions (
    position_id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    title       TEXT NOT NULL,
    job_family  TEXT NOT NULL,
    grade       TEXT NOT NULL,
    created_at  TIMESTAMPTZ NOT NULL DEFAULT now(),
    updated_at  TIMESTAMPTZ NOT NULL DEFAULT now(),
    deleted_at  TIMESTAMPTZ,
    UNIQUE (title, grade)           -- ensures that the combination of title and grade is unique,
);                                  -- while allowing the same title across different grades and the same grade across different titles

CREATE TABLE company.employees (
    employee_id             UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    employee_no             TEXT UNIQUE NOT NULL,
    first_name              TEXT NOT NULL,
    last_name               TEXT NOT NULL,
    date_of_birth           DATE NOT NULL,
    email_work              TEXT UNIQUE NOT NULL,
    phone_work              TEXT,
    hire_date               DATE NOT NULL,
    termination_date        DATE,
    current_department_id   UUID REFERENCES company.departments(department_id)
                            ON UPDATE CASCADE ON DELETE SET NULL,
    current_position_id     UUID REFERENCES company.positions(position_id)
                            ON UPDATE CASCADE ON DELETE SET NULL,
    is_manager              BOOLEAN NOT NULL DEFAULT FALSE,
    country                 TEXT NOT NULL,
    lawful_basis            TEXT NOT NULL,
    created_at              TIMESTAMPTZ NOT NULL DEFAULT now(),
    updated_at              TIMESTAMPTZ NOT NULL DEFAULT now(),
    deleted_at              TIMESTAMPTZ
);


CREATE TABLE company.app_users (
    actor_id     TEXT PRIMARY KEY,
    employee_id  UUID REFERENCES company.employees(employee_id)
                         ON UPDATE CASCADE ON DELETE SET NULL,
    role         company.user_role NOT NULL,
    description  TEXT
);


--SCHEMA: FINANCE
CREATE TABLE finance.salary_bands (
    band_id     UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    job_family  TEXT NOT NULL,
    grade       TEXT NOT NULL,
    min_salary  NUMERIC(12,2) NOT NULL CHECK (min_salary >= 0),
    max_salary  NUMERIC(12,2) NOT NULL CHECK (max_salary >= min_salary),
    currency    TEXT NOT NULL,
    created_at  TIMESTAMPTZ NOT NULL DEFAULT now(),
    updated_at  TIMESTAMPTZ NOT NULL DEFAULT now(),
    UNIQUE (job_family, grade, currency)
);


CREATE TABLE finance.employee_compensation (
    comp_id            UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    employee_id        UUID NOT NULL REFERENCES company.employees(employee_id)
                                   ON UPDATE CASCADE ON DELETE CASCADE,
    band_id            UUID REFERENCES finance.salary_bands(band_id)
                                   ON UPDATE CASCADE ON DELETE SET NULL,
    base_salary_amount NUMERIC(12,2) NOT NULL CHECK (base_salary_amount >= 0),
    currency           TEXT NOT NULL,
    effective_from     DATE,
    effective_to       DATE CHECK (effective_to IS NULL OR effective_from IS NULL OR effective_to >= effective_from),
    created_at         TIMESTAMPTZ NOT NULL DEFAULT now(),
    updated_at         TIMESTAMPTZ NOT NULL DEFAULT now(),
    UNIQUE (employee_id, effective_from)
);


CREATE TABLE finance.payment_details_ref (
    payment_ref_id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    employee_id    UUID NOT NULL REFERENCES company.employees(employee_id)
                               ON UPDATE CASCADE ON DELETE CASCADE,
    s3_bucket      TEXT NOT NULL,
    s3_key         TEXT NOT NULL,
    kms_key_alias  TEXT NOT NULL,
    created_at     TIMESTAMPTZ NOT NULL DEFAULT now()
);


--SCHEMA: EVENTS

-- This block creates ENUM types in the "events" schema if they do not exist yet
-- They fix allowed values for artifact type, actor type, and audit result
-- The IF NOT EXISTS check makes the script safe to run many times
DO $$
BEGIN
  IF NOT EXISTS ( 
    SELECT 1 FROM pg_type t JOIN pg_namespace n ON n.oid = t.typnamespace
    WHERE t.typname = 'artifact_type' AND n.nspname = 'events'
  ) THEN
    CREATE TYPE events.artifact_type AS ENUM (
      'payment_details',
      'sick_leave_summary',
      'address_change',
      'business_trip',
      'reimbursement',
      'insurance_claim',
      'sensitive_note'
    );
  END IF;

  IF NOT EXISTS (
    SELECT 1 FROM pg_type t JOIN pg_namespace n ON n.oid = t.typnamespace
    WHERE t.typname = 'actor_type' AND n.nspname = 'events'
  ) THEN
    CREATE TYPE events.actor_type AS ENUM ('user','system','job','service');
  END IF;

  IF NOT EXISTS (
    SELECT 1 FROM pg_type t JOIN pg_namespace n ON n.oid = t.typnamespace
    WHERE t.typname = 'audit_result' AND n.nspname = 'events'
  ) THEN
    CREATE TYPE events.audit_result AS ENUM ('allow','deny','error');
  END IF;
END $$;


CREATE TABLE events.external_artifacts (
    artifact_id   UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    employee_id   UUID NOT NULL REFERENCES company.employees(employee_id)
                               ON UPDATE CASCADE ON DELETE CASCADE,
    artifact_type events.artifact_type NOT NULL,
    s3_bucket     TEXT NOT NULL,
    s3_key        TEXT NOT NULL,
    hash_sha256   TEXT,
    kms_key_alias TEXT NOT NULL,
    created_at    TIMESTAMPTZ NOT NULL DEFAULT now()
);


CREATE TABLE events.audit_events (
    event_id    UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    actor_type  events.actor_type   NOT NULL,
    actor_id    TEXT                NOT NULL,
    event_type  TEXT                NOT NULL,
    object_ref  TEXT,
    result      events.audit_result NOT NULL,
    details     JSONB,
    occurred_at TIMESTAMPTZ         NOT NULL
);