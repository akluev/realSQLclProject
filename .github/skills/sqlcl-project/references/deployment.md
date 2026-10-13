# Project deployment

Use this workflow only when the user requests deployment.

## Resolve the target

The target environment is a material choice. Resolve it from the user's request or governing workspace instructions. If it remains ambiguous, stop and ask which environment to deploy to. Do not infer an environment from a connection name.

## Prerequisites

- All required source and changeset work is committed unless the governing deployment policy explicitly says otherwise.
- The target has an appropriate restore point or rollback plan when required.
- The required SQLcl MCP server and connection are available.
- SQLcl is version 26.1 or later.

## Deploy

1. Connect to the confirmed target through MCP and inspect schema information.
2. Use the MCP SQLcl-command tool to verify the SQLcl working directory.
3. Change to the project's `dist` directory through the MCP SQLcl command interface when needed.
4. Run `@install.sql` through MCP.
5. Review the complete output for Liquibase failures, `ORA-` errors, compilation errors, invalid objects, or an unexpectedly empty schema.

Successful output normally reports executed changesets or that the database is current, followed by successful schema compilation and no invalid objects.

## Post-deployment validation

Run project-appropriate validation queries through MCP. At minimum, confirm that the expected schemas contain objects and have no unexpected invalid objects:

```sql
select count(*) as total_objects
  from all_objects
 where owner = '<SCHEMA>';

select count(*) as invalid_count
  from all_objects
 where owner = '<SCHEMA>'
   and status = 'INVALID';
```

## Changelog ordering

The include order in `stage.changelog.xml` must respect dependencies:

1. users and roles;
2. required grants;
3. tables and other base objects;
4. constraints and dependent objects;
5. seed or reference DML.

If deployment fails, diagnose and report the failing changeset and prerequisite. Do not reorder or rerun changesets blindly.
