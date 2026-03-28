# GitHub Copilot Instructions — SQLcl Project (Sharable)

Transferable skills and patterns developed for Oracle database projects managed with SQLcl's Liquibase-based
deployment pipeline (`project stage` / `project export` / `project stage add-custom`).

---

## Connection Verification

**CRITICAL:** Before running ANY SQLcl project commands, verify that a database connection is established.

### Connection Check Process

1. Check if a connection is currently active using `mcp_sqlcl_local_list-connections`
2. If no connection is active, inform the user:
   
   > ⚠️ **No database connection detected.** You need to set a connection in project preferences before running these commands.
   
3. Do not attempt to run project commands without an active connection

### Project-Specific Connection

Some projects may specify a required connection in their `.github/copilot-instructions.md`. Always use the specified connection for that project.

---

## Tool Responsibilities and Execution Timing

### SQLcl Project Commands

| Command | Purpose | Copilot Can Run? | Frequency |
|---------|---------|------------------|-----------|
| `project export -o <OBJECTS>` | Syncs database objects back to source files under `src/database/<schema>/`. Run after DDL changes to keep source files current. | **No** — MCP has a bug. Offer the command for user to copy-paste into SQLcl. | **Frequent** — after each DDL change during feature development. |
| `project stage add-custom -file-name <name>.sql` | Creates a new **custom** DML file (seed data, reference data) under `dist/releases/next/changes/<branch>/_custom/`. | **Yes** — run in terminal via MCP. | **As needed** — when adding seed/reference data during feature development. |
| `project stage` | Generates/updates DDL changeset files from database metadata under `dist/releases/next/changes/<branch>/` and rebuilds the changelog controller. | **Never** — user runs this manually at end of feature. | **Infrequent** — once or twice near the end of feature development. No benefit to running constantly since it rebuilds the entire controller. |

### Critical Rules

- **Never run `project stage`** as Copilot. This is a deliberate end-of-feature milestone command that the user triggers when ready to package changes.
- **Never manually create files under `dist/releases/`** — always use `project stage` or `project stage add-custom` so they're properly registered in the changelog controller. **Editing files after creation is expected** (e.g., populating DML statements, splitting changesets).
- For DML/seed data files, use **only** `project stage add-custom`, never `project stage`.

### Typical Feature Development Flow

1. Create/modify database objects (tables, packages, etc.) via MCP/SQLcl.
2. After each DDL change, offer: `project export -o <OBJECT_NAME>` for user to run.
3. Create DML/seed data files using `project stage add-custom` as needed.
4. Near feature completion, user runs `project stage` once or twice to consolidate changesets.
5. If requested, split changeset files per the rules below.

---

## Branch Immutability Rule

Once a release branch (e.g. `v1`) has been deployed, **do not modify its changeset files**.  
All subsequent changes go into a new working branch (e.g. `v2`).

### Updating Lookup Data from Deployed Branches

If a lookup table's original DML lives in a deployed branch `_custom` folder, add incremental  
`UPDATE`, `MERGE`, `INSERT`, or `DELETE` statements as needed in a new `_custom` file under the current branch instead of editing the deployed file.

**Why:** This preserves the audit trail and respects branch immutability. Liquibase will execute both the original seed data (from v1) and the incremental changes (from v2) in sequence.

**How:**
1. Use `project stage add-custom -file-name <table>_updates.sql` to create a new file in the current branch.
2. Write only the incremental DML needed (UPDATE/MERGE/INSERT/DELETE).
3. The original deployed file remains untouched.

**Example:**  
Original: `dist/releases/next/changes/v1/_custom/status_codes_dml.sql` (deployed)  
Incremental: `dist/releases/next/changes/v2/_custom/status_codes_updates.sql` (new)

---

## Workflow 1: DML File Creation (`project stage add-custom`)

Use for seed / reference data (lookup tables, static configuration).

### Steps
1. Run **`project stage add-custom -file-name <table>_dml.sql`** in the terminal via MCP.
2. The file is created in `dist/releases/next/changes/<branch>/_custom/<table>_dml.sql` with a generated changeset ID. **Do not change the changeset ID.**
3. Populate the file body below the existing header lines based on the scenario (see templates below).
4. Only add `runOnChange:true` to the changeset header if explicitly asked.

### Template 1: Initial Population (New Tables)

Use when initially populating a lookup table for the first time. The DELETE makes it safe to re-run in dev environments.

```sql
-- liquibase formatted sql
-- changeset SqlCl:<generated-id> stripComments:false logicalFilePath:<branch>\_custom\<table>_dml.sql
-- sqlcl_snapshot dist\releases\next\changes\<branch>\_custom\<table>_dml.sql:null:null:custom

DELETE FROM <schema>.<table>;

INSERT INTO <schema>.<table> (...) VALUES (...);
INSERT INTO <schema>.<table> (...) VALUES (...);
...
```

### Template 2: Incremental Updates (Existing Tables)

Use when modifying existing lookup data. Write **surgical DML** based on what actually changed:

**Adding/populating a new column:**
```sql
-- liquibase formatted sql
-- changeset SqlCl:<generated-id> stripComments:false logicalFilePath:<branch>\_custom\<table>_updates.sql
-- sqlcl_snapshot dist\releases\next\changes\<branch>\_custom\<table>_updates.sql:null:null:custom

UPDATE <schema>.<table> SET new_column = 'value' WHERE id = 1;
UPDATE <schema>.<table> SET new_column = 'other' WHERE id = 2;
```

**Removing obsolete rows:**
```sql
DELETE FROM <schema>.<table> WHERE status_code IN ('OBSOLETE1', 'OBSOLETE2');
```

**Adding new rows:**
```sql
-- DELETE first for dev safety (allows re-running)
DELETE FROM <schema>.<table> WHERE status_code IN ('NEW1', 'NEW2');

INSERT INTO <schema>.<table> (...) VALUES ('NEW1', ...);
INSERT INTO <schema>.<table> (...) VALUES ('NEW2', ...);
```

**Goal:** Write only the DML that reflects the actual change, not a full reload.

### Advanced: Preconditions (RARE - only when user requests)

**Key insight:** `runOnChange:true` and preconditions are ALWAYS applied by **editing an existing file**, never when creating a new file.

**Typical scenario:**
1. Business provides seed data via spreadsheet (job titles, departments, etc.)
2. Data is loaded to UAT on branch v1, testers start working with it
3. Business provides UPDATED data BEFORE prod deployment (still on v1)
4. Problem: Need fresh data in prod, but can't wipe UAT data (testers are using it)

**Solution:** Edit the existing file on v1 and add `runOnChange:true` + precondition to skip re-running in UAT (where table already has data) but load fresh in prod (where table is empty).

**User request pattern:** "Update data in this file from this table and make it rerunable if the table is empty in target env."

**vs. Post-deployment updates:** If updated data comes AFTER prod deployment, use Template 2 (Incremental Updates) in a NEW branch with a NEW file - no preconditions needed.

**Implementation:**
```sql
-- liquibase formatted sql
-- changeset SqlCl:<generated-id> stripComments:false runOnChange:true logicalFilePath:<branch>\_custom\<table>_dml.sql
-- preconditions onFail:MARK_RAN
-- precondition-sql-check expectedResult:0 SELECT COUNT(*) FROM <schema>.<table>
-- sqlcl_snapshot dist\releases\next\changes\<branch>\_custom\<table>_dml.sql:null:null:custom

DELETE FROM <schema>.<table>;
INSERT INTO <schema>.<table> (...) VALUES (...);
...
```

**Effect:**
- UAT: Precondition fails (table has data), changeset skips (MARK_RAN)
- Prod: Precondition passes (table is empty), changeset runs and loads data

**Do not add preconditions unless explicitly requested by the user.**

---

## Workflow 2: Object Export (Sync Source Files)

After creating or modifying database objects (tables, packages, views, etc.), source files under `src/database/<schema>/` must be synced.

### Steps
1. Determine which objects were created or changed.
2. **Offer** the following command for the user to copy-paste into SQLcl (MCP cannot run `project export` due to a bug):
   ```
   project export -o <comma-separated list of objects>
   ```
   
### Example
After creating table `DEPT` and `EMP`:
```
project export -o DEPT,EMP
```

After modifying package spec and body `GRAPH_MAIN`:
```
project export -o GRAPH_MAIN
```

**Do not run this command yourself** — provide it in the chat for the user to execute.

---

## Workflow 3: Post-Stage Changeset Splitting

This is a **pure file editing workflow** triggered after the user has run `project stage`. No project commands are executed by Copilot in this workflow.

After `project stage` runs, SQLcl groups all DDL for an object into a **single changeset**. Each DDL statement must become its own numbered changeset so that Liquibase can track and selectively re-run individual steps.

**When to apply:** User asks to "split table changeset", "split changesets", or similar language after running `project stage`.  
**Applies only to:** Files under `dist/releases/next/changes/<branch>/<schema>/tables/`.

### Per-file transformation steps

1. **Skip** the file if it already has dotted changeset IDs (e.g. `:ID.1`) — do not re-process.
2. Move `-- sqlcl_snapshot ...` to **line 2** (immediately after `-- liquibase formatted sql`), before any changeset header.
3. Remove the original single `-- changeset AUTHOR:ID ...` line entirely.
4. Insert a new numbered changeset header immediately before each SQL statement:
   - `-- changeset AUTHOR:ID.1 ...`
   - `-- changeset AUTHOR:ID.2 ...`
   - … and so on
   - Preserve the exact `stripComments` and `logicalFilePath` values from the original header.
5. Every statement delimited by `;` or `/` gets its own header — one header per statement, no exceptions.
6. **Blank line rule:** Add a blank line before each changeset comment (except the very first one after `sqlcl_snapshot`). No blank line between the changeset comment and its SQL statement.

### Target format

```sql
-- liquibase formatted sql
-- sqlcl_snapshot src/database/<schema>/tables/<table>.sql:null:<hash>:create

-- changeset AUTHOR:<ID>.1 stripComments:false logicalFilePath:<branch>\<schema>\tables\<table>.sql
create table <schema>.<table> (
    col1 number not null,
    col2 varchar2(100)
);

-- changeset AUTHOR:<ID>.2 stripComments:false logicalFilePath:<branch>\<schema>\tables\<table>.sql
alter table <schema>.<table>
    add constraint <table>_pk primary key (col1) using index enable;

-- changeset AUTHOR:<ID>.3 stripComments:false logicalFilePath:<branch>\<schema>\tables\<table>.sql
alter table <schema>.<table> add constraint <table>_uk unique (col2) using index enable;
```

### Alter-only files (no `create table`)

When the file contains only `alter table` statements (incremental changes to an existing table),  
the same rules apply — each `alter` gets its own numbered changeset. Use `/` as the statement  
terminator if the original file used `/`.

```sql
-- liquibase formatted sql
-- sqlcl_snapshot src/database/<schema>/tables/<table>.sql:<old_hash>:<new_hash>:alter

-- changeset AUTHOR:<ID>.1 stripComments:false logicalFilePath:<branch>\<schema>\tables\<table>.sql
alter table <schema>.<table> add (
    new_col varchar2(200)
)
/

-- changeset AUTHOR:<ID>.2 stripComments:false logicalFilePath:<branch>\<schema>\tables\<table>.sql
alter table <schema>.<table>
    add constraint <table>_ck1 check (new_col is not null) enable
/
```

### Ordering matters

The changeset numbers must reflect the **required execution order**. If a constraint drop must precede
a column drop (because Oracle would fail otherwise), place the DROP CONSTRAINT changeset first — even
if its logical number appears out of sequence relative to the original script. The numbers are labels,
not a strict mandate; correctness of execution order takes priority.

### Processing order — SEQUENTIAL only

When splitting multiple files in a directory, **always process one file at a time**:

1. `read_file` the current file.
2. Apply the transformation and write it with `replace_string_in_file`.
3. Announce completion and move to the next file.

**Never read multiple files in parallel.** **Never edit multiple files in parallel.**  
Process them one-by-one in directory order. This prevents context overflow and makes it easy to spot mistakes early.

---

## MCP / SQLcl Tips

- Always reconnect if queries fail with `ORA-17008: Closed connection`.
- Use `all_tab_columns where owner = 'SCHEMA_NAME'` for metadata queries — avoids needing DBA privileges.
