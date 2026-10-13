# Custom SQLcl Project files

Use `project stage add-custom` for seed data, reference data, assertion migrations, APEX workspace setup, and other migrations that SQLcl Project does not generate as native object changes.

## Core workflow

1. Run `project stage add-custom -file-name <name>.sql` through the SQLcl MCP command tool from the project root.
2. Locate the generated file under `dist/releases/next/changes/<branch>/_custom/`.
3. Preserve its generated Liquibase header, author, changeset ID, logical path, and snapshot metadata.
4. Replace only the placeholder body with the required SQL.
5. Add `runOnChange:true` or preconditions only when the user explicitly requests or the governing workflow requires them.
6. Confirm the generated stage changelog includes the custom file.

Never create a custom file or changelog include manually.

## Branch immutability

Do not edit a custom changeset belonging to a deployed release branch. Create a new incremental custom file in the current branch instead. Preserve the earlier file as deployment history.

## Initial lookup population

For a new lookup table, a development-safe initial file may delete the target rows and insert the authoritative set:

```sql
-- liquibase formatted sql
-- changeset SqlCl:<generated-id> stripComments:false logicalFilePath:<branch>\_custom\<table>_dml.sql
-- sqlcl_snapshot dist\releases\next\changes\<branch>\_custom\<table>_dml.sql:null:null:custom

DELETE FROM <schema>.<table>;

INSERT INTO <schema>.<table> (...) VALUES (...);
```

Use schema-qualified table names for seed and reference DML when required by workspace conventions.

## Incremental lookup updates

For an existing deployed dataset, write only the required `INSERT`, `UPDATE`, `MERGE`, or `DELETE` statements in a new current-branch file. Do not replace an incremental change with a full reload.

When adding a known set of rows, deleting just those keys before inserting them can make development reruns safe:

```sql
DELETE FROM <schema>.<table> WHERE status_code IN ('NEW1', 'NEW2');

INSERT INTO <schema>.<table> (...) VALUES ('NEW1', ...);
INSERT INTO <schema>.<table> (...) VALUES ('NEW2', ...);
```

## Optional rerun precondition

Use `runOnChange:true` and a precondition only when explicitly requested, commonly when a pre-production seed file must reload in an empty target while remaining skipped in an environment that already contains test data:

```sql
-- liquibase formatted sql
-- changeset SqlCl:<generated-id> stripComments:false runOnChange:true logicalFilePath:<branch>\_custom\<table>_dml.sql
-- preconditions onFail:MARK_RAN
-- precondition-sql-check expectedResult:0 SELECT COUNT(*) FROM <schema>.<table>
-- sqlcl_snapshot dist\releases\next\changes\<branch>\_custom\<table>_dml.sql:null:null:custom

DELETE FROM <schema>.<table>;
INSERT INTO <schema>.<table> (...) VALUES (...);
```

## APEX workspace and users

For initial project setup, create separate generated custom files for:

1. workspace creation with `apex_instance_admin.add_workspace`;
2. workspace-user creation with `apex_util.set_workspace` and `apex_util.create_user`.

Use the public `apex_instance_admin` and `apex_util` APIs, not versioned internal APEX packages. Keep workspace creation separate because it is normally one-time, while user creation may be repeated for additional users.

Example workspace body:

```sql
BEGIN
  apex_instance_admin.add_workspace(
    p_workspace      => 'WORKSPACE_NAME',
    p_primary_schema => 'SCHEMA_NAME'
  );
END;
/
```

Example user body:

```sql
BEGIN
  apex_util.set_workspace('WORKSPACE_NAME');

  apex_util.create_user(
    p_user_name                    => 'USERNAME',
    p_first_name                   => 'First',
    p_last_name                    => 'Name',
    p_email_address                => 'user@example.com',
    p_web_password                 => 'password',
    p_developer_privs              => 'ADMIN:CREATE:DATA_LOADER:EDIT:HELP:MONITOR:SQL',
    p_default_schema               => 'SCHEMA_NAME',
    p_change_password_on_first_use => 'N'
  );
END;
/
```
