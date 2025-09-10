#pip install faker psycopg2-binary python-dotenv
#DATABASE_URL="postgresql://user:pass@localhost:5432/yourdb" --> to .env

from dicts_for_synth import DEPARTMENTS_DEF, GRADES, EMAIL_DOMAINS, CITY_CODES, ROLES, ROLE_DESCRIPTIONS, JOB_FAMILIES
import os, sys, random, uuid
from datetime import date, datetime, timezone, timedelta
import psycopg2
from psycopg2.extras import execute_values
from faker import Faker
from dotenv import load_dotenv

load_dotenv()
fake = Faker()
Faker.seed(42)
random.seed(42)

DB_URL = os.getenv("DATABASE_URL")
if not DB_URL:
    print("ERROR: set DATABASE_URL=postgresql://user:pass@host:port/dbname in .env")
    sys.exit(1)

N_EMPLOYEES = 144
COMPANY_BIRTH = date(2025, 1, 1)

def now_iso():
    return datetime.now(timezone.utc).isoformat()

def noon_utc(d):
    return datetime(d.year, d.month, d.day, 12, 0, 0, tzinfo=timezone.utc).isoformat()

def rand_date_between(start, end):
    days = (end - start).days
    return start + timedelta(days=random.randint(0, max(0, days)))

def phone():
    code = random.choice(CITY_CODES)
    return f"+49-{code}-{random.randint(1000000, 9999999)}"

def salary_base_for(family):
    return {
        "Human Resources": 45000,
        "Audit": 52000,
        "Finance": 55000,
        "Management": 70000,
        "Development": 60000,
        "Design": 50000,
        "Marketing": 48000,
        "Research & Development": 65000,
    }.get(family, 50000)

def grade_mult(grade):
    return {"P1": 0.9, "P2": 1.0, "P3": 1.2, "P4": 1.4, "P5": 1.7}[grade]

def main():
    conn = psycopg2.connect(DB_URL)
    conn.autocommit = False
    cur = conn.cursor()

    try:
        dept_rows = []
        dept_code_to_id = {}
        for code, name in DEPARTMENTS_DEF:
            did = str(uuid.uuid4())
            dept_code_to_id[code] = did
            dept_rows.append((did, code, name, noon_utc(COMPANY_BIRTH), noon_utc(COMPANY_BIRTH)))

        execute_values(cur,
            """INSERT INTO COMPANY.DEPARTMENTS
               (department_id, code, name, created_at, updated_at)
               VALUES %s""",
            dept_rows
        )

        pos_rows = []
        for code, name in DEPARTMENTS_DEF:
            specs = JOB_FAMILIES.get(name, [f"{name} Role"])
            for title in random.sample(specs, k=min(3, max(2, len(specs))))[:3]:
                pid = str(uuid.uuid4())
                pos_rows.append((pid, title, name, random.choice(GRADES), noon_utc(COMPANY_BIRTH), noon_utc(COMPANY_BIRTH)))

        execute_values(cur,
            """INSERT INTO COMPANY.POSITIONS
               (position_id, title, job_family, grade, created_at, updated_at)
               VALUES %s""",
            pos_rows
        )

        pos_by_family = {}
        for pid, title, family, grade, *_ in pos_rows:
            pos_by_family.setdefault(family, []).append((pid, grade))

        band_rows = []
        band_key_to_id= {}
        for family in JOB_FAMILIES.keys():
            for g in GRADES:
                cur_code = "EUR"
                bid = str(uuid.uuid4())
                lo = int(salary_base_for(family) * grade_mult(g))
                hi = int(lo * 1.25)
                band_rows.append((bid, family, g, f"{lo:.2f}", f"{hi:.2f}", cur_code, noon_utc(COMPANY_BIRTH), noon_utc(COMPANY_BIRTH)))
                band_key_to_id[(family, g, cur_code)] = bid

        execute_values(cur,
            """INSERT INTO FINANCE.SALARY_BANDS
               (band_id, job_family, grade, min_salary, max_salary, currency, created_at, updated_at)
               VALUES %s""",
            band_rows
        )

        today = date.today()
        emp_rows = []
        user_rows = []

        for i in range(N_EMPLOYEES):
            emp_id = str(uuid.uuid4())
            code, dname = random.choice(DEPARTMENTS_DEF)
            dept_id = dept_code_to_id[code]

            pos_candidates = pos_by_family.get(dname) or [(pos_rows[0][0], pos_rows[0][3])]
            pos_id, pos_grade = random.choice(pos_candidates)

            fname = fake.first_name()
            lname = fake.last_name()

            domain = random.choice(EMAIL_DOMAINS)
            email = f"{fname.lower()}.{lname.lower()}{i}@{domain}"

            hire = rand_date_between(COMPANY_BIRTH, today)

            emp_rows.append((emp_id,f"E-{1000+i}",fname,lname,
                fake.date_of_birth(minimum_age=22, maximum_age=60).isoformat(),
                email, phone(), hire.isoformat(), None, dept_id, pos_id, random.random() < 0.18, "DE",
                random.choice([
                    "Art.6(1)(b) GDPR – employment contract",
                    "Art.6(1)(c) GDPR – legal obligation",
                    "Art.6(1)(f) GDPR – legitimate interests"
                ]), now_iso(), now_iso(),None
            ))

            role = random.choices(population=ROLES, weights=[18, 14, 12, 8, 18, 5, 5], k=1)[0]
            description = random.choice(ROLE_DESCRIPTIONS[role])
            user_rows.append((f"user_{i}", emp_id, role, description))

        execute_values(cur,
            """INSERT INTO COMPANY.EMPLOYEES
               (employee_id, employee_no, first_name, last_name, date_of_birth, email_work, phone_work,
                hire_date, termination_date, current_department_id, current_position_id, is_manager,
                country, lawful_basis, created_at, updated_at, deleted_at)
               VALUES %s""", emp_rows
        )

        execute_values(cur,
            """INSERT INTO COMPANY.APP_USERS
               (actor_id, employee_id, role, description)
               VALUES %s""", user_rows
        )
    
    except Exception as e:
        conn.rollback()
        print("ERROR during seeding:", e)
        raise
    finally:
        cur.close()
        conn.close()