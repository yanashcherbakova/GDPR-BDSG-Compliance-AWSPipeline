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
ROLE_DESCRIPTIONS = {
    "HR": [
        "Human Resources Specialist",
        "HR Operations Coordinator",
        "Talent Acquisition Partner",
        "Payroll & Benefits Associate",
    ],
    "Accountant": [
        "Finance & Accounting Specialist",
        "Accounts Payable/Receivable",
        "Controlling & Reporting Analyst",
        "Treasury Operations Associate",
    ],
    "Manager": [
        "Team Manager / Project Lead",
        "People Manager",
        "Operations Manager",
        "Program Manager",
    ],
    "MedicalConsultant": [
        "Occupational Health Consultant",
        "Employee Health Advisor",
        "Medical Leave Case Manager",
        "Workplace Wellness Consultant",
    ],
    "Analyst": [
        "Business Analyst",
        "Data Analyst",
        "Compliance Data Analyst",
        "People Analytics Analyst",
    ],
    "DPO": [
        "Data Protection Officer",
        "Privacy Compliance Officer",
        "GDPR/BDSG Compliance Officer",
        "Privacy Governance Lead",
    ],
    "System": [
        "System Service Account",
        "Automation Job Account",
        "Integration Service Account",
        "Data Pipeline Service Account",
    ],
}

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