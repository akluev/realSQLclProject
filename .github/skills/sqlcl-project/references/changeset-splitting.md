# Post-stage changeset splitting

Apply this file-editing workflow after the agent runs `project stage`, or when the user asks to split changesets produced by an earlier stage. Do not run another project command merely to split files.

SQLcl may place several DDL statements for one object under one changeset. Each statement must have its own numbered changeset so Liquibase can track and rerun it independently.

## Scope

Process generated DDL files under `dist/releases/next/changes/<branch>/<schema>/` and comparable DDL directories when they contain a single unsuffixed changeset ID. Skip a file that already uses dotted IDs such as `:123.1`.

## Transformation

For each file:

1. Move its generated `-- sqlcl_snapshot ...` line to line 2, immediately after `-- liquibase formatted sql`.
2. Remove the original unsuffixed changeset header.
3. Insert one numbered header before every SQL statement: `.1`, `.2`, and so on.
4. Preserve the generated author, base ID, `stripComments`, `logicalFilePath`, and all other generated attributes.
5. Treat statements delimited by `;` or `/` as separate statements.
6. Add a blank line before each changeset comment except the first comment after the snapshot line. Do not place a blank line between a changeset comment and its statement.
7. Keep statements in dependency-safe execution order. For example, drop a constraint before dropping a column that depends on it.

Target shape:

```sql
-- liquibase formatted sql
-- sqlcl_snapshot src/database/<schema>/tables/<table>.sql:<old-hash>:<new-hash>:alter

-- changeset AUTHOR:<ID>.1 stripComments:false logicalFilePath:<branch>\<schema>\tables\<table>.sql
alter table <schema>.<table> drop constraint <constraint_name>
/

-- changeset AUTHOR:<ID>.2 stripComments:false logicalFilePath:<branch>\<schema>\tables\<table>.sql
alter table <schema>.<table> drop column <column_name>
/
```

## Sequential processing

Process files one at a time in directory order:

1. Read one file.
2. Transform and write that file.
3. Verify its statement count, numbered headers, terminators, and preserved metadata.
4. Continue to the next file.

Do not read or edit several generated DDL files in parallel. Sequential handling keeps statement boundaries and ordering reviewable.
