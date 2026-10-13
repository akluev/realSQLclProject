---
name: sqlcl-project
description: 'Oracle SQLcl Project deployment pipeline skill. Use when: project export, project stage, project stage add-custom, DML file creation, changeset splitting, Liquibase changesets, deploy install.sql, stage.changelog.xml, branch immutability, MCP SQLcl connection, seed data, lookup table DML, APEX workspace setup via SQLcl, APEXlang compile apex import, APEXlang validate apex validate, prj_compile, prj_validate.'
---

# SQLcl Project Workflows

Use these workflows for Oracle database projects managed with SQLcl Project and its Liquibase-based deployment pipeline.

## Required MCP boundary

This workflow requires an available SQLcl MCP server exposing the tools needed for the requested operation. Resolve the server and tool prefix from the active runtime; never hardcode an MCP server name.

Before any database query, SQLcl Project command, or preparatory filesystem mutation:

1. Confirm that the required SQLcl MCP tools are advertised and callable. Depending on the operation, these normally include the equivalents of `connections_list`, `connect`, `schema_information`, `sql_run`, `sqlcl_run`, and `request_status`.
2. Resolve the connection from the user or governing workspace instructions. Do not infer the database environment or username from a connection name.
3. Connect through MCP. If the requested connection is already active, continue. Do not switch a different active connection without user confirmation.
4. Call the MCP schema-information tool before generating SQL or querying the database.

If the required MCP server, tool, connection, or schema inspection is unavailable, stop and report the exact missing capability. Do not invoke a locally installed `sql` or `sqlcl` executable, open an interactive SQLcl session, use JDBC directly, or substitute another database client. MCP configuration entries and resources do not prove that command tools are available; the required tools must be callable in the current runtime.

Older SQLcl MCP releases may expose equivalent tools under older names. Use the callable equivalent advertised by the active server rather than assuming a fixed prefix or spelling.

## Shared rules

- Honor a project-specific connection named in `AGENTS.md`, `CLAUDE.md`, `.github` instructions, or a shared conventions file.
- Set `current_schema` as required by the workspace before ad-hoc queries.
- Use the MCP SQL execution tool for queries and the MCP SQLcl-command tool for SQLcl commands, file compilation, export, stage, and deployment operations.
- Compile DDL source through the MCP SQLcl-command tool with `@<absolute-file-path>`; do not inline DDL into a query tool.
- Run exports asynchronously when the MCP server supports asynchronous execution, then poll the returned request with its status tool.
- Never manually create files under `dist/releases/`. Create them with `project stage` or `project stage add-custom`, then edit the generated files when the workflow requires it.
- Do not modify changesets belonging to a deployed release branch. Put later changes in the current release branch.
- Do not commit generated changesets automatically. Leave them for user review unless the user explicitly requests a commit.

## Choose the workflow

Read only the references needed for the request:

- **Object or application export:** [references/object-export.md](references/object-export.md)
- **Ordinary `project stage`:** [references/project-stage.md](references/project-stage.md), followed by [references/changeset-splitting.md](references/changeset-splitting.md)
- **`project stage add-custom`, seed/reference data, or APEX workspace setup:** [references/custom-files.md](references/custom-files.md)
- **Split generated multi-statement changesets:** [references/changeset-splitting.md](references/changeset-splitting.md)
- **Deploy with `dist/install.sql`:** [references/deployment.md](references/deployment.md)
- **Compile or validate APEXlang:** [references/apexlang.md](references/apexlang.md)

When another skill needs only custom-file creation or changeset splitting, it should read this entrypoint and only those references, not every SQLcl Project workflow.
