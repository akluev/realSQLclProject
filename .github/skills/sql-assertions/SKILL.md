---
name: sql-assertions
description: 'Work with Oracle SQL assertions on Oracle AI Database 26ai RU 23.26.1 or later, including creating, reviewing, listing, exporting by name, table dependency, or schema, and staging assertion DDL. Use whenever a user asks to use an assertion against an Oracle database connection, or mentions CREATE ASSERTION, ALTER ASSERTION, DROP ASSERTION, USER_ASSERTIONS, DBA_ASSERTIONS, assertion dependencies, assertion export, or assertion changes staged through SQLcl Project custom changesets.'
---

# Oracle SQL Assertions

Use this skill whenever a user asks to use an SQL assertion against an Oracle database connection, as well as for exporting or staging assertion DDL that SQLcl Project does not currently support natively. Do not confuse Oracle SQL assertions with application or test-framework assertions.

For assertion syntax, privileges, restrictions, and errors, read [references/sql-language.md](references/sql-assertions.md) before generating or reviewing assertion DDL. Export and staging are separate modes; neither one implicitly runs the other.

For a request to stage assertion changes, read [references/staging.md](references/staging.md); it drives `project stage add-custom` and the bundled `stage-assertion.sh` script, which applies the changeset-splitting rules. Assertion staging is a separate operation from export and must never be triggered implicitly by an export request.

## Export safety boundary

An assertion export reads database metadata and synchronizes local assertion source files. It may delete local files within the resolved export scope, but it must never create, alter, or drop assertion objects in the database. Execute assertion DDL only when the user explicitly requests a database change.

In an export request, wording such as "drop and recreate assertions" means delete and recreate the corresponding local assertion files unless the user explicitly says to modify the database objects.

## Database version requirement

Oracle SQL assertions require Oracle AI Database 26ai RU 23.26.1 or later. Before performing any assertion operation against a live database connection, verify the connected database version:

```sql
select banner_full from v$version;
```

If the connected database is older than RU 23.26.1, stop before querying assertion dictionary views or generating or executing assertion DDL. Tell the user that the connected database version does not support Oracle SQL assertions and that RU 23.26.1 or later is required. Do not silently substitute another integrity mechanism; if the user wants an alternative, use the pre-26ai guidance in [references/sql-language.md](references/sql-language.md).

If the returned version cannot establish that the minimum is met, report that assertion support could not be verified and ask for a compatible connection or definitive version information. Static review of assertion source does not require a live version check.

## Connection resolution

Use a SQLcl MCP connection explicitly supplied by the user or unambiguously specified by governing workspace instructions. Never hardcode a development connection in this skill and never infer a connection from its name.

This workflow requires an available SQLcl MCP server exposing the tools needed for the requested assertion operation. Resolve the server and tool prefix from the active runtime; never hardcode an MCP server name. Before querying the database or deleting, replacing, or generating assertion files, confirm that the required MCP connection, schema-inspection, SQL, and SQLcl-command tools are advertised and callable.

If the required MCP server or tools are missing or fail, stop and report the exact unavailable capability. Do not invoke a locally installed `sql` or `sqlcl` executable, open an interactive SQLcl session, use JDBC directly, or substitute another database client. An MCP configuration entry or resource listing is not evidence that command tools are available.

If the connection is missing or ambiguous, stop and ask exactly:

> Provide the MCP server connection.

After connecting, follow the SQLcl MCP requirement to inspect schema information before querying the database. Do not switch an existing active connection without user confirmation.

## Resolve the requested scope

Identify the operation before changing files:

- **List**: show assertion names and requested metadata; do not write files.
- **Export named assertions**: delete each requested assertion's local file if present, then recreate it from the exact database row. If a requested assertion no longer exists in the database, leave its local file deleted and report that result. Do not delete unrelated files.
- **Export assertions related to a table**: query the assertion dependency view first and resolve the distinct assertions currently related to that table. Delete only those assertions' local files, then export each resolved assertion. Assertions deleted from the database no longer have dependency rows, so this mode cannot identify or remove their stale local files; report this limitation without broadening cleanup.
- **Export all assertions for a schema**: empty only that schema's resolved local `assertions` directory, then export every assertion currently present for that schema. This is a complete local mirror operation and requires no separate "refresh" request.
- **Find assertions related to a table**: use the assertion dependency view and report the matching assertions without writing files when export was not requested.
- **Stage assertion changes**: compare assertion source with the configured Git default branch and create SQLcl Project custom changesets. Use committed source by default, or the working tree only when the user explicitly waives the assertion-staging commit prerequisite for that invocation. This exception applies only to the custom assertion workflow, never to ordinary `project stage`. Follow [references/staging.md](references/staging.md).

Resolve schemas from the user's explicit list or, when requested, the `schemas` array in `project.config.json`. In a SQLcl Project workspace, prefer `.dbtools/project.config.json`. Normalize ordinary unquoted schema names to uppercase for dictionary queries and lowercase for directory names.

The default project destination is:

```text
src/ext/<schema-lowercase>/assertions/<assertion-name-lowercase>.sql
```

Use a different root only when the user or workspace conventions specify one.

## Choose the dictionary view

Choose once for the resolved export scope:

1. More than one schema: use `DBA_ASSERTIONS` and `DBA_ASSERTION_DEPENDENCIES`.
2. Exactly one schema: query the session identity:

```sql
select user as session_user,
       sys_context('USERENV', 'CURRENT_SCHEMA') as current_schema
  from dual;
```

3. If `SESSION_USER` equals the requested schema, use `USER_ASSERTIONS` and `USER_ASSERTION_DEPENDENCIES`.
4. Otherwise, use the `DBA_` views and filter by `OWNER`.

`CURRENT_SCHEMA` is diagnostic context; the single-schema decision is based on `SESSION_USER`. If the required `DBA_` views are inaccessible, stop and report the missing dictionary access. Do not silently change scope or connect as another user.

## Discover assertions

Build the metadata query from the user's wording: a name, a list, a pattern such as `A%`, a schema, or several schemas. Select metadata only, never `DEFINITION_SQL`; the spool script reads that per assertion.

For one schema owned by the connected user:

```sql
select user as owner,
       assertion_name,
       status,
       deferrable,
       deferred,
       validated
  from user_assertions
 order by assertion_name;
```

For multiple schemas, or a schema different from the connected user:

```sql
select owner,
       assertion_name,
       status,
       deferrable,
       deferred,
       validated
  from dba_assertions
 where owner in ('SCHEMA_1', 'SCHEMA_2')
 order by owner, assertion_name;
```

Use exact predicates for named exports and `like` for patterns. Validate requested/configured schema and assertion values as Oracle identifiers before placing them in SQL literals.

To find assertions related to a table, query the matching dependency view. For example:

```sql
select owner,
       assertion_name,
       referenced_owner,
       referenced_name,
       referenced_type,
       validation_type,
       validation_event
  from dba_assertion_dependencies
 where owner in ('SCHEMA_1', 'SCHEMA_2')
   and referenced_owner = 'TABLE_OWNER'
   and referenced_name = 'TABLE_NAME'
 order by owner, assertion_name;
```

For `USER_ASSERTION_DEPENDENCIES`, omit `OWNER` and filter the referenced object the same way. An empty result means no visible dependency rows were recorded; report that result without inventing dependencies.

## Map assertions to files

One assertion per file at `src/ext/<owner-lowercase>/assertions/<assertion-name-lowercase>.sql`. The scripts derive every path from the owner and assertion name; never pass or invent paths. They reject names with filesystem-unsafe characters. If two assertion names map to the same case-insensitive filename, stop and ask the user to choose a reversible filename policy.

The file format, snapshot trailer, hash, and staging decision rules are specified in [references/format.md](references/format.md). The scripts implement them; you do not need to read that file to export or stage, and you must not reproduce the scripts' work by hand.

## Scripts

All scripts live in this skill's `scripts/` directory (`<skill-dir>/scripts`, the folder that contains this `SKILL.md`, for example `.claude/skills/sql-assertions/scripts`). Each one handles **exactly one** assertion or file; you drive the loop and make the decisions.

- Run shell scripts from the **project root** as `bash "<skill-dir>/scripts/<script>.sh" …`, also from PowerShell. Quote every argument. On Windows, `bash` is Git Bash.
- Success means exit code `0` and the expected file. On a non-zero exit, show the user the script's stderr message; never work around it by hand.
- The scripts check that `git` is on `PATH` and that they run from the repository root. If that check fails, relay its message (usually a `PATH` problem) and stop.
- On Windows, Git Bash may fail to start inside a restricted sandbox with an MSYS2 `CreateFileMapping ... Win32 error 5` message before the script runs. Request permission to rerun the exact same command with the required sandbox escalation. Do not change the command, and do not treat this as permission to bypass the SQLcl MCP boundary for database work.

## Export assertions

1. Verify the version, connection, and scope, and choose the dictionary view (sections above).
2. Run the **metadata query** for the requested scope through MCP `sql_run` (see **Discover assertions**). Do not select `DEFINITION_SQL` here.
3. Prepare each schema before its first row:
   - "export all assertions" for a schema: `bash "<skill-dir>/scripts/export-assertion.sh" --prepare <OWNER> --clean`. This empties that schema's `assertions` directory, and nothing else.
   - any other scope: `bash "<skill-dir>/scripts/export-assertion.sh" --prepare <OWNER>`.
   - For a named assertion that the metadata query did not return, delete only its destination file and report it as absent from the database.
4. For **each row**, in order:
   1. For every row after the schema's first, run `bash "<skill-dir>/scripts/export-assertion.sh" --prepare <OWNER>` again, never with `--clean`. Each successful export removes the empty `assertions/tmp/` directory, and without it the next spool fails with `SP2-0556: Invalid file name`. `--clean` here would delete the files already exported in this run.
   2. One MCP `sqlcl_run` call:
      ```text
      @<absolute skill-dir>/scripts/spool-assertion.sql <USER|DBA> <OWNER> <ASSERTION_NAME> <absolute project root>
      ```
      `USER` or `DBA` follows the dictionary-view choice. For `USER`, `<OWNER>` is the session user.
   3. One shell call, with the values from the metadata row:
      ```bash
      bash "<skill-dir>/scripts/export-assertion.sh" <OWNER> <ASSERTION_NAME> <STATUS> "<DEFERRABLE>" <DEFERRED> "<VALIDATED>"
      ```
      It prints `OK <file> <hash> <state>`. Any other result means that assertion failed: tell the user `export of <OWNER>.<ASSERTION_NAME> failed: <stderr>` and continue with the next row.
5. Finish each prepared schema once, even when the metadata query returned no rows: `bash "<skill-dir>/scripts/export-assertion.sh" --finish <OWNER>`. It removes the empty `assertions/tmp/` directory and prints `DONE`. If exports failed, it lists their leftover files instead.
6. Report:
   - the connection and dictionary view, and why that view;
   - the assertions found;
   - the files written, with their hashes;
   - the files deleted;
   - any failures; the script keeps `assertions/tmp/` for diagnosis, so report that path.

   For a table-scoped export, also report that files for assertions absent from the database cannot be found through dependency views.

Do not run SQLcl Project staging or create custom changesets as part of an export workflow. Stage only when the user explicitly requests assertion staging.
