# Legal Aspects

This project addresses **the legal context** of handling **sensitive data** through a protection pipeline based on **AWS Macie** and **AWS KMS**. The analysis is not limited to the tools themselves but follows the **entire lifecycle of data** within an organization.
From **data modeling** to **access control** and **DPO oversight**, each stage is examined with regard to relevant compliance obligations and risks.

In this document, I aim to outline the **key legal aspect**, placing them in line with the **chronological development** of my project.


# I. Legal Aspect at the Database Modeling Stage

## 1.1. Use of Universally Unique Identifiers (UUIDs)

**UUID (Universally Unique Identifier)** is a 128-bit value designed to provide a unique reference for records in a database.
Unlike incremental IDs (1, 2, 3, …), UUIDs are not predictable and do not carry information about the sequence of data creation. This makes them technically useful for distributed systems and legally relevant **for privacy protection**.

### Why UUIDs in our database?

In our database design, UUIDs are used as **primary keys** for `employees` and related entities.  
This choice is not only technical but also supports legal compliance:

- **[GDPR Article 4(5) — Pseudonymisation](https://eur-lex.europa.eu/legal-content/EN/TXT/PDF/?uri=CELEX:32016R0679#page=33) (official PDF)**  
  UUIDs act as neutral identifiers. On their own, they reveal nothing about the individual.  
  Only when combined with a lookup table (e.g., `UUID` → `name`, `email`) can they be linked to a person.  
  This makes them effective for **pseudonymisation** at the schema level.  

- **[GDPR Article 25 — Data Protection by Design and by Default](https://eur-lex.europa.eu/legal-content/EN/TXT/PDF/?uri=CELEX:32016R0679#page=48) (official PDF)**  
Using UUIDs from the very beginning reduces identifiability by default, aligning with the principle of privacy by design.  

- **[BDSG §26 — Employee Data Processing](https://www.gesetze-im-internet.de/bdsg_2018/__26.html)**  
  German law limits processing to what is necessary for employment.  
  By separating **technical identifiers** (UUIDs) from **direct identifiers** (`name`, `email`, `IBAN`), data minimisation is achieved and risks of unnecessary exposure are reduced.


❗PENDING: db column pic (!)

## 1.2. Lawful Bases for Data Processing

In our company database, the **employees** table includes a dedicated column `lawful_basis`.
This field records the legal ground for processing employee data in accordance with **GDPR Article 6**.

### Purpose of this design

❗PENDING: db column pic (!)

- **Privacy by design ([GDPR Art. 25](https://eur-lex.europa.eu/legal-content/EN/TXT/PDF/?uri=CELEX:32016R0679#page=48)):** compliance is integrated already at the modeling stage, not added later.  
- **Traceability:** each employee record is linked to a specific lawful basis.  
- **Audit-readiness:** DPOs and auditors can easily verify that no personal data exists in the system without a valid justification.  


### Lawful bases considered ([GDPR Art. 6](https://eur-lex.europa.eu/legal-content/EN/TXT/PDF/?uri=CELEX:32016R0679#page=36))

- **Art. 6(1)(a) — `Consent`**  
  *Example:* employee consents to the publication of a photo on the company website.  
- **Art. 6(1)(b) — `Contract`**  
  *Example:* payroll and HR processing required by the employment contract.  
- **Art. 6(1)(c) — `Legal obligation`**  
  *Example:* tax and social security reporting mandated by law.  
- **Art. 6(1)(d) — `Vital interests`**  
  *Example:* sharing medical information in an emergency.  
- **Art. 6(1)(e) — `Public task`**  
  *Example:* processing required for public interest or official authority (mostly public sector).  
- **Art. 6(1)(f) — `Legitimate interests`**  
  *Example:* workplace security via CCTV, provided employee rights are not overridden.  

### Why it matters?

Embedding the lawful basis directly into the schema:  
- provides **transparency for the DPO**, who can immediately verify the legal ground for each dataset,
- ensures early compliance with **GDPR and BDSG requirements** by embedding them at the modeling stage, which in turn reduces **company costs** by avoiding later redesign.








