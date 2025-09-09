#pip install faker psycopg2-binary python-dotenv
#DATABASE_URL="postgresql://user:pass@localhost:5432/yourdb" --> to .env

from __future__ import annotations
import os, sys, random
from datetime import date, datetime, timezone, timedelta
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

DEPARTMENTS_DEF = [
    ("HR",   "Human Resources"),
    ("AUD",  "Audit"),
    ("FIN",  "Finance"),
    ("MNG",  "Management"),
    ("DVLP", "Development"),
    ("DES",  "Design"),
    ("MRKT", "Marketing"),
    ("RND",  "Research & Development"),
]

GRADES = ["P1", "P2", "P3", "P4", "P5"]
COUNTRIES = ["DE", "US", "FR", "PL"]

EMAIL_DOMAINS = ["gmail.com", "dataforge.io"]
CITY_CODES = ["30", "89", "40", "69", "211", "221", "231", "341"]
ROLES = ["HR", "Accountant", "Manager", "MedicalConsultant", "Analyst", "DPO", "System"]

JOB_FAMILIES = {
    "Human Resources": ["HR Generalist", "Talent Acquisition", "Payroll & Benefits", "MedicalConsultant"],
    "Audit": ["Internal Audit", "Compliance", "Risk & Controls"],
    "Finance": ["Accounting", "Financial Planning & Analysis", "Controlling", "Treasury"],
    "Management": ["Executive Leadership", "Project Management", "Operations Management"],
    "Development": ["Software Engineering", "QA / Testing", "DevOps / Cloud", "Data Engineering"],
    "Design": ["UX/UI Design", "Graphic Design", "Product Design"],
    "Marketing": ["Content Marketing", "Performance Marketing", "PR & Communications", "Brand Management"],
    "Research & Development": ["Research Scientist", "Data Science"],
}

ARTIFACT_TYPES = [
            "payment_details",
            "sick_leave_summary",
            "address_change",
            "business_trip",
            "reimbursement",
            "insurance_claim",
            "sensitive_note",
        ]

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