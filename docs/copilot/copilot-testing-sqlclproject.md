# SQLcl Project Copilot Testing - Interaction Log

This document captures successful interactions testing Copilot's ability to handle SQLcl project-bound workflows.

**Related Documentation:**
- [VM Configuration Guide](../vm/README.md) — Instructions for setting up test VMs with APEX and ORDS
- [13. Integrating SQLcl Project with GitHub Copilot](../13.-Integrating-SQLcl-Project-with-GitHub-Copilot.md) — Copilot setup and MCP configuration

- [SQLcl Project Copilot Testing - Interaction Log](#sqlcl-project-copilot-testing---interaction-log)
  - [Test Case 1: Export Tables to Repository](#test-case-1-export-tables-to-repository)
  - [Test Case 2: Export Table Data to DML Files](#test-case-2-export-table-data-to-dml-files)
  - [Test Case 3: Add Records and Update DML File](#test-case-3-add-records-and-update-dml-file)
  - [Test Case 4: Split Table Changesets](#test-case-4-split-table-changesets)
  - [Test Case 5: Add Column, Populate Data, and Export (Feature Branch)](#test-case-5-add-column-populate-data-and-export-feature-branch)

---

**Initial Setup:**
- User is working in branch `feature-1`
- Project is configured for schemas `FOO` and `BAR`
- Copilot instructions specify MCP server `sqlcl_local` and connection `proj_vm`
- EMP and DEPT tables have been created in the database

---

## Test Case 1: Export Tables to Repository

**User Request:**
> We created table emp and dept in foo schema, help me to export them to the repo.

**Agent Actions:**
1. Read SQLcl project instructions to understand workflow
2. Provided export command: `project export -o DEPT,EMP`
3. Explained the command syncs database object definitions to `src/database/foo/tables/`

**Result:** ✅ Provided correct export command per project workflow.

---

## Test Case 2: Export Table Data to DML Files

**User Request:**
> Export emp and dept data in dml files.

**Agent Actions:**
1. Created DML files using `project stage add-custom` for both tables:
   - `dept_dml.sql`
   - `emp_dml.sql`
2. Queried dept table data (4 rows)
3. Queried emp table data (14 rows)
4. Populated both DML files with DELETE + INSERT statements following Template 1 (Initial Population)

**Result:** ✅ Successfully created and populated DML files in `dist/releases/next/changes/feature-1/_custom/`.

---

## Test Case 3: Add Records and Update DML File

**User Request:**
> Add two employees alex and bob into emp and rerun dml export for emp.

**Agent Actions:**
1. Inserted two new employee records:
   - Alex (empno 7935, CLERK, dept 10)
   - Bob (empno 7936, CLERK, dept 30)
2. Queried updated emp table (now 16 rows)
3. Updated `emp_dml.sql` with all 16 employee records

**Result:** ✅ Successfully added records and regenerated DML file with updated data.

---

**Setup Change:** User completed development on `feature-1` and ran `project stage` to generate DDL changesets.

---

## Test Case 4: Split Table Changesets

**User Request:**
> Do table DDL splits.

**Agent Actions:**
1. Found 4 table changeset files in `dist/releases/next/changes/feature-1/`
2. Processed each file sequentially (one at a time):
   - Moved `sqlcl_snapshot` comment to line 2
   - Removed original single changeset header
   - Added numbered changeset headers (`.1`, `.2`, etc.) for each DDL statement
   - Applied proper blank line formatting
3. Split files: `emp.sql` (2 changesets), `dept.sql` (2 changesets), `t.sql` (1 changeset), `q.sql` (1 changeset)

**Result:** ✅ Successfully split all table changesets following Workflow 3 rules.

---

**Setup Change:** User merged `feature-1` into `main` and created new branch `feature-2` to continue development.

---

## Test Case 5: Add Column, Populate Data, and Export (Feature Branch)

**User Request:**
> Add a field icon to dept table and populate it with Font Awesome icons that make sense for the department, after that give me a command to export dept table and generate the DML file.

**Agent Actions:**
1. Connected to `proj_vm` database (project-specific connection)
2. Executed `ALTER TABLE foo.dept ADD (icon VARCHAR2(50))`
3. Populated icon values with appropriate Font Awesome icons:
   - ACCOUNTING (deptno 10) → `fa-calculator`
   - RESEARCH (deptno 20) → `fa-flask`
   - SALES (deptno 30) → `fa-shopping-cart`
   - OPERATIONS (deptno 40) → `fa-cogs`
4. Created incremental DML file using `project stage add-custom -file-name dept_icon_updates.sql`
5. Populated `dist/releases/next/changes/feature-2/_custom/dept_icon_updates.sql` with UPDATE statements
6. Provided export command: `project export -o DEPT`

**Result:** ✅ Successfully added column, populated data, created DML file, and provided correct export command.
