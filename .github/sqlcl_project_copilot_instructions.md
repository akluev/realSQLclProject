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

## MCP SQLcl Connection Pattern

**CRITICAL:** Follow this sequence every time before executing SQL commands via MCP:

### Connection Workflow

```
1. Call: mcp_sqlcl_local_connect(connection_name: "<connection_name>")
2. If successful → proceed with mcp_sqlcl_local_run-sql or mcp_sqlcl_local_run-sqlcl
3. If error "already connected" → ignore and proceed with commands
```

### Key Rules

- **Always attempt connection first** — Do not check if already connected, just call `connect`
- **Ignore "already connected" errors** — This is normal and safe, proceed with SQL execution
- **Never skip connection step** — Even if you think a connection exists from a previous call
- **Use run-sqlcl for DDL compilation** — `@filepath` syntax: `mcp_sqlcl_local_run-sqlcl` with `@c:\full\path\to\file.sql`
- **Use ASYNCHRONOUS for exports** — `project export` commands use `executionType: ASYNCHRONOUS`
- **Set current_schema before queries** — Always `alter session set current_schema = <schema>` before SELECT queries. The schema to use should be known at this point: check `.github/copilot-instructions.md` first, or inspect `.dbtools/project.config.json` to see if the project has a single schema. If in any doubt — **stop and ask the user** before proceeding.

### Example Pattern

```javascript
// 1. Connect (always)
mcp_sqlcl_local_connect(connection_name: "<connection_name>")

// 2. Execute DDL via file
mcp_sqlcl_local_run-sqlcl(
  executionType: SYNCHRONOUS,
  sqlcl: "@c:\\repo\\tests\\demo1\\src\\database\\demo1\\tables\\job.sql"
)

// 3. Export object
mcp_sqlcl_local_run-sqlcl(
  executionType: ASYNCHRONOUS,
  sqlcl: "project export -o JOB"
)

// 4. Run query
mcp_sqlcl_local_run-sql(
  connectionName: "proj_vm",
  sql: "alter session set current_schema = <schema>;\nselect * from <table>"
)
```

---

## Tool Responsibilities and Execution Timing

### SQLcl Project Commands

| Command | Purpose | Copilot Can Run? | Frequency |
|---------|---------|------------------|-----------|
| `project export -o <OBJECTS>` | Syncs database objects back to source files under `src/database/<schema>/`. Run after DDL changes to keep source files current. | **Conditional** — if SQLcl ≥ 26.1, run directly via MCP; otherwise offer the command for user to copy-paste. See Workflow 2. | **Frequent** — after each DDL change during feature development. |
| `project stage add-custom -file-name <name>.sql` | Creates a new **custom** DML file (seed data, reference data) under `dist/releases/next/changes/<branch>/_custom/`. | **Yes** — run in terminal via MCP. | **As needed** — when adding seed/reference data during feature development. |
| `project stage` | Generates/updates DDL changeset files from database metadata under `dist/releases/next/changes/<branch>/` and rebuilds the changelog controller. | **Conditional** — if SQLcl ≥ 26.1, run via MCP (after `git commit`); if < 26.1, user runs manually. See Workflow 3. | **Infrequent** — once or twice at end-of-feature. Always follow with changeset splitting (Workflow 4). |

### Critical Rules

- **`project stage` via MCP (SQLcl 26.1+)**: User must commit work first. Copilot runs stage, then **DO NOT COMMIT** — user reviews generated changesets first. Always follow `project stage` with Workflow 4 (changeset splitting).
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

### Version Check — Required Before Every Export

Before running or offering an export, check the **actual SQLcl binary version** (not the project config):
```
version
```
or 
```
define _sqlplus_release
```
- Result `SQLcl version ≥ 26.1` or `_sqlplus_release >= 2601000000` (SQLcl 26.1+): **run the export directly via MCP** using `mcp_sqlcl_local_run-sqlcl` with `executionType: ASYNCHRONOUS`, then poll with `mcp_sqlcl_local_dbtools-get-tool-request` until complete.
- Result `SQLcl version < 26.1` or `_sqlplus_release < 2601000000` (older SQLcl): **offer the command** for the user to copy-paste into SQLcl instead.

### Steps (SQLcl ≥ 26.1 — targeted export)
1. Determine which objects were created or changed.
2. **For APEX app exports** (`APEX.<app_id>`): delete all files under `src/database/<schema>/apex_apps/f<app_id>/` **before** exporting. This ensures components removed from the app don't linger as stale files.
3. Run via MCP: `project export -o <comma-separated list of objects>`
4. Poll until complete and confirm success to the user.

### Steps (SQLcl ≥ 26.1 — full export)

A full export (`project export` with no `-o`) re-exports everything configured in `.dbtools/filters/project.filters`. Because it covers APEX applications, stale files must be removed first — but only for the apps actually in scope per the filters.

1. **Stage current work first:** run `git add .` in the terminal. This ensures any pre-existing changes are staged so the export result can be reviewed (and rolled back with `git checkout` if something goes wrong).

2. **Determine in-scope APEX apps from the filters file:**
   - Read `.dbtools/filters/project.filters`.
   - Collect all **uncommented** predicates that reference `APEX_APPLICATIONS` or `application_id` (ignore lines starting with `--` or inside `/* ... */` blocks).
   - Build and run this query via MCP:
     ```sql
     select application_id from apex_applications where <predicate_1> and <predicate_2> ...
     ```
   - **Strip table prefixes** when building the query: `APEX_APPLICATIONS.application_group` → `application_group`.
   - Example: if the filters contain `application_id in (139)` and `APEX_APPLICATIONS.application_group = 'Prod'`, run:
     ```sql
     select application_id from apex_applications
      where application_id in (139)
        and application_group = 'Prod'
     ```
   - The result is the exact list of app IDs to pre-delete.

3. **Pre-delete only those app folders:** for each `app_id` returned, delete `src/database/<schema>/apex_apps/f<app_id>/`.

4. **Run the full export via MCP:** `project export`

5. Poll until complete and confirm success to the user.

### Steps (SQLcl < 26.1 — offer copy-paste)
1. Determine which objects were created or changed.
2. Inform the user with this message (adapt as needed):

   > ⚠️ **SQLcl < 26.1 detected.** Due to a known bug in this version, I can't run `project export` for you directly. Please copy and run the command below in your SQLcl terminal. **Upgrade to SQLcl 26.1 or later and I'll run it automatically next time.**

3. Provide the command for the user to copy-paste:
   ```
   project export -o <comma-separated list of objects>
   ```

### Examples
After creating table `DEPT` and `EMP`:
```
project export -o DEPT,EMP
```

After modifying package spec and body `GRAPH_MAIN`:
```
project export -o GRAPH_MAIN
```

After modifying APEX app 139 (pre-delete `src/database/cla_apex/apex_apps/f139/` first):
```
project export -o APEX.<app_id>
```

---

## Workflow 3: Project Stage (SQLcl ≥ 26.1) & Changeset Review

Use when user explicitly asks to "stage project", "run stage", "consolidate changesets", or similar — direct request to execute `project stage`.

### Prerequisites

- SQLcl ≥ 26.1 (check actual binary: `version` command or `define _sqlplus_release` - must be ≥ 2601000000)
- **All work must be committed** before staging: `git add .` followed by `git commit`

### Steps

1. **Version check**: Run `version` or `define _sqlplus_release` to verify actual SQLcl binary is ≥ 26.1. If < 26.1, inform user: "Your SQLcl is < 26.1. Please run `project stage` manually in your terminal."

2. **Ensure committed state**: Check for uncommitted changes in the `src/` folder. If found, offer to stage them with `git add .` and commit with `git commit`. Only committed changes in `src/` are processed by stage.

3. **Run `project stage` via MCP**:
   ```
   cd <project_root>
   connect -name <connection>
   project stage
   ```

4. **Review output**: Expect output showing:
   - Branches being compared (usually the current branch against the `defaultBranch` configured in `.dbtools/project.config.json`)
   - Summary of objects exported (TABLES, REF_CONSTRAINTS, APEX_APPLICATIONS, etc.)
   - Files generated under `dist/releases/next/changes/<branch>/<schema>/`
   - Modified changelog files (stage.changelog.xml, main.changelog.xml, etc.)

5. **IMPORTANT: DO NOT COMMIT YET**
   - Review generated changesets in `dist/releases/next/changes/<branch>/<schema>/`
   - Proceed to **Workflow 4** (Changeset Splitting) to split multi-statement DDL files if needed
   - After splitting, user commits the results
   - **Note:** Copilot automatically runs Workflow 4 after Workflow 3; user can also manually request changeset splitting later if `project stage` was run outside of Copilot

### Key Notes

- **Filters**: Review `.dbtools/filters/project.filters` to understand which objects are exported
- **Branching**: Stage compares the current branch against the `defaultBranch` configured in `.dbtools/project.config.json` (typically `main`). Working on feature branches keeps changesets organized
- **Idempotent**: Stage can be re-run after filtering adjustments — it regenerates changesets from git diffs

---

## Workflow 4: Post-Stage Changeset Splitting

This is a **pure file editing workflow** that applies post-stage DDL files. It can be triggered in two scenarios:

1. **Automatically** — after Copilot runs Workflow 3 (`project stage`) via MCP
2. **On-demand** — when user manually runs `project stage` and then asks Copilot to "split table changes" or similar

No project commands are executed in this workflow.

After `project stage` runs (manually or via Copilot), SQLcl groups all DDL for an object into a **single changeset**. Each DDL statement must become its own numbered changeset so that Liquibase can track and selectively re-run individual steps.

**Applies only to:** Files under `dist/releases/next/changes/<branch>/<schema>/tables/` and similar DDL directories that have single (non-dotted) changeset IDs.

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

## APEX Workspace and Admin User Setup

For projects using Oracle APEX, create the workspace and admin user as part of the base release via `project stage add-custom`.

### Workflow: Create Workspace and Admin User

**When:** During initial project setup, after database user and schema are created.

**Best Practice:** Split into two separate scripts:
1. **Workspace creation** — one-time setup (may fail if workspace already exists)
2. **User creation** — can be re-run to add more users to existing workspace

**Steps:**

#### Script 1: Create Workspace

1. Create custom file: `project stage add-custom -file-name apex_workspace_setup.sql`

2. Populate with workspace creation:
   ```sql
   -- liquibase formatted sql
   -- changeset SqlCl:<generated-id> stripComments:false logicalFilePath:<branch>\_custom\apex_workspace_setup.sql
   -- sqlcl_snapshot dist\releases\next\changes\<branch>\_custom\apex_workspace_setup.sql:null:null:custom

   BEGIN
     apex_instance_admin.add_workspace(
       p_workspace => 'WORKSPACE_NAME',
       p_primary_schema => 'SCHEMA_NAME'
     );
   END;
   /

   COMMIT;
   ```

#### Script 2: Create Users

1. Create custom file: `project stage add-custom -file-name apex_workspace_<workspace>_users.sql`

2. Populate with user creation:
   ```sql
   -- liquibase formatted sql
   -- changeset SqlCl:<generated-id> stripComments:false logicalFilePath:<branch>\_custom\apex_workspace_<workspace>_users.sql
   -- sqlcl_snapshot dist\releases\next\changes\<branch>\_custom\apex_workspace_<workspace>_users.sql:null:null:custom

   BEGIN
     apex_util.set_workspace('WORKSPACE_NAME');

     apex_util.create_user(
       p_user_name => 'USERNAME',
       p_first_name => 'First',
       p_last_name => 'Name',
       p_email_address => 'user@example.com',
       p_web_password => 'password',
       p_developer_privs => 'ADMIN:CREATE:DATA_LOADER:EDIT:HELP:MONITOR:SQL',
       p_default_schema => 'SCHEMA_NAME',
       p_change_password_on_first_use => 'N'
     );

   END;
   /

   COMMIT;
   ```

### Testing

Run scripts via MCP to test before committing:
```sql
@dist/releases/next/changes/<branch>/_custom/apex_workspace_setup.sql
@dist/releases/next/changes/<branch>/_custom/apex_workspace_<workspace>_users.sql
```

Validate success by querying public synonym views:
```sql
select workspace, apex_users from apex_workspaces where workspace = 'WORKSPACE_NAME';
select workspace_name, user_name, is_admin from apex_workspace_apex_users where workspace_name = 'WORKSPACE_NAME';
```

### Key Rules

- **Use public synonyms only**: `apex_instance_admin`, `apex_util` (never `APEX_240200.WWV_FLOW_INSTANCE_ADMIN`, etc.)
- **Split scripts**: Keeps workspace creation (one-time) separate from user creation (repeatable)
- **COMMIT statements**: Optional for Liquibase, but helpful for manual testing/debugging
- **Sequence**: Workspace first, then set workspace context, then create user

---

---

## Project Deployment

### Deployment Protocol

**CRITICAL:** When user requests deployment, always confirm the target environment if not explicitly stated. Refer to the project's `.github/copilot-instructions.md` for environment definitions.

**If environment is ambiguous:**
- STOP and ask: "Which environment do you want to deploy to?"
- List available environments from copilot-instructions
- Wait for user confirmation before proceeding

### Prerequisites

- ✅ All changes committed to git
- ✅ Target environment baseline restore point created (recommended for safety)
- ✅ SQLcl 26.1+ with MCP connected

### Step-by-Step Deployment Procedure

#### 1. **Connect to Target Environment**

Look up the connection name from copilot-instructions environment table:
```sqlcl
conn -name <connection_name>
```

#### 2. **Verify Current Location**
```sqlcl
pwd
```
Expected: `<project_root>/dist`

If not in `dist`, navigate there:
```sqlcl
cd dist
```

**Note:** `cd` is a SQLcl command. If you see `CD-001: dist is not a directory`, you're not at project root.

#### 3. **Execute Installation**
```sqlcl
@install.sql
```

This script:
- Sets SQLcl environment (define off, blank lines on)
- Runs Liquibase (`lb update`) with changelog controller
- Executes changesets in order (from `dist/releases/next/changes/<branch>/stage.changelog.xml`)
- Runs recompilation on all project schemas
- Validates all objects compiled successfully

#### 4. **Analyze Output**

**✅ Expected Output (Success):**
```
Installing/updating schemas
Database is up to date, no changesets to execute
OR
Running Changeset: <file>::<id>::<author>
Compiling <SCHEMA> ...Done!
Invalid objects:
0 rows selected.
```

**❌ Error Indicators (Failure):**
- `Migration failed, error reported:`
- `ORA-XXXXX:` (any Oracle error)
- `ERROR: Exception Details:`
- `0 rows selected` for object count (deployment blocked early)
- Any invalid objects listed
- Any compilation errors reported

#### 5. **Post-Deployment Validation**

Run verification queries via MCP (adjust schema name per project):
```sql
-- Count objects (must be > 0)
select count(*) as total_objects from all_objects where owner = '<SCHEMA>';

-- Check invalid objects (must be 0)
select count(*) as invalid_count 
from all_objects 
where owner = '<SCHEMA>' and status = 'INVALID';

-- List all objects
select object_name, object_type, status 
from all_objects 
where owner = '<SCHEMA>' 
order by object_type, object_name;
```

**Success Criteria:**
- ✅ Total objects > 0
- ✅ Invalid count = 0
- ✅ Data counts match expectations (if applicable)

### Changelog Controller & Execution Order

**Critical Concept:** SQLcl executes changesets in the order they appear in `stage.changelog.xml`. The file **MUST** respect database object dependencies.

**Dependency Rules:**
1. Create users/roles before granting to them
2. Grant permissions before users create objects
3. Create tables before adding constraints
4. Create tables before inserting data
5. Create base objects before dependent views/synonyms

**Broken Order Example:**
```xml
<include file="sys/object_grants/user_role_privs.sql"/>   <!-- GRANT to demo1 -->
<include file="cla_deployer/users/demo1.sql"/>             <!-- CREATE user -->
```
**Result:** `ORA-01917: user or role 'DEMO1' does not exist`

**Why:** Liquibase tries to grant before user exists.

**Correct Order:**
```xml
<include file="cla_deployer/users/demo1.sql"/>             <!-- Step 1: Create user -->
<include file="sys/object_grants/user_role_privs.sql"/>   <!-- Step 2: Grant permissions -->
<include file="demo1/tables/dept.sql"/>                   <!-- Step 3: Create tables -->
<include file="demo1/ref_constraints/fk_deptno.sql"/>     <!-- Step 4: Add constraints -->
<include file="_custom/dept_dml.sql"/>                    <!-- Step 5: Load data -->
```

### Troubleshooting Deployment Failures

#### Scenario 1: Oracle Error During Changeset

**Error:** `ORA-01917: user or role 'DEMO1' does not exist`

**Diagnosis:**
1. ✅ Dependency ordering issue? Review `stage.changelog.xml` — prerequisites must come first
2. ✅ Environment issue? Check target schema exists, user has privileges
3. ✅ Changeset content issue? Review SQL file, run manually to understand error

**Resolution:**
- If ordering: Edit `stage.changelog.xml`, reorder includes, commit, retry
- If environment: Create missing users/objects, retry
- If changeset: Fix SQL, `project export`, retry

#### Scenario 2: Zero Objects

**Diagnosis:** Deployment blocked early — search for first "Migration failed" or "ERROR" in output

**Resolution:**
1. Find first failing changeset
2. Fix root cause (usually dependency ordering)
3. Flashback to restore point (if available), retry

#### Scenario 3: Invalid Objects After Deployment

**Error:** Compilation errors reported

**Diagnosis:** Objects created but have compilation errors due to:
- Missing dependent objects
- Wrong schema references
- DDL ordering issue

**Resolution:**
1. Fix object code
2. `project export -o <object>`
3. Retry deployment (Liquibase re-executes invalid changesets)

### Testing Deployment with Restore Points

**Safe testing pattern:**

1. Create baseline restore point (see VM reference documentation)
2. Run deployment: `@install.sql`
3. If fails, flashback to restore point
4. Fix and retry (database is clean)

### Copilot Deployment Assistance

When executing deployment, Copilot:
1. **Pre-checks** — Verifies connection, location, environment
2. **Execution** — Runs `@install.sql` from `dist`
3. **Analysis** — Reviews output for errors, invalid objects
4. **Validation** — Queries schema to confirm object counts/status
5. **Reporting** — States success/failure with findings
6. **Troubleshooting** — Analyzes root cause if failed

---

## MCP / SQLcl Tips

- Always reconnect if queries fail with `ORA-17008: Closed connection`
- Use `all_tab_columns where owner = 'SCHEMA_NAME'` for metadata queries — avoids needing DBA privileges
