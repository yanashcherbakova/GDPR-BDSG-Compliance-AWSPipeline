# Project Chronology


## Day 1 (September 4, 2025)
- Studied **AWS Macie** capabilities for sensitive data protection
- Reviewed how data isolation is implemented inside companies
- Analyzed company responsibilities for data storage and protection under **[GDPR](https://eur-lex.europa.eu/eli/reg/2016/679/oj)** and **[BDSG](https://www.gesetze-im-internet.de/bdsg_2018/)**
- Started drafting the [database schema](synth_data/db_preparation) in **db_preparation**
- Established the need for **UUIDs** and explicit **lawful basis** tracking at the modeling stage to 

## Day 2 (September 5, 2025)
- Ongoing refinement of [database schema](synth_data/db_preparation)
- Started [Legal Aspects](Legal_Aspects.md) — this document will serve as the main space for notes and clarifications on legal aspects throughout the project
- Added sections: [UUIDs (§1.1)](Legal_Aspects.md#11-use-of-universally-unique-identifiers-uuids), [Lawful Bases (§1.2)](Legal_Aspects.md#12-lawful-bases-for-data-processing)
- Linked GDPR/BDSG references


## Day 3 (September 8, 2025)
- Finished the [database schema](synth_data/db_preparation)
- Studied the legal aspects of audits – their role and implementation
- Added new section: [Audit Events Logging (§1.3)](Legal_Aspects.md#13-audit-events-logging)
- Created the SQL script [`create_db_postgres.sql`](synth_data/create_db_postgres.sql) for database setup
- Database successfully created


## Day 4 (September 9, 2025)
- Finished the script for synthetic data generation and automatic database filling - [`synth_data_generation.py`](synth_data/synth_data_generation.py)
- Database filled with synthetic data
- Displayed the current ER diagram

![ER-diagram](pic/dataforge_db.png)