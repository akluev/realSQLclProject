# Private database links and the changesets that use them

Use this reference for two related requests:

- **Part A:** create (or recreate) a private database link through a custom
  changeset, for example "create a custom changeset for the REMOTE database link".
- **Part B:** rewrite staged changesets for objects that select through such a
  link, for example materialized views. Typical requests: "refresh my
  materialized view changesets", "fix the MV changesets", "wrap the MVs again
  after staging", or a deployment that fails with ORA-02019.

"Refresh my MV changesets" means rewriting the staged changeset **files** as
described in Part B. It does not mean refreshing materialized view data with
`dbms_mview.refresh`. If the request could mean either, ask.

## Why a temporary definer-rights procedure

The deployer (for example `APP_DEPLOYER`, a DBA) runs every changeset as itself.

- A private database link can only be created by its owner. The deployer cannot
  create `APP_OWNER.REMOTE`; a `create database link app_owner.remote` statement
  treats `app_owner.remote` as the link name.
- Private database links are resolved in the schema of the user running the
  statement, so the deployer cannot see `APP_OWNER.REMOTE`. DDL such as
  `create materialized view app_owner.my_mv ... from tbl@remote` fails with:

  ```text
  ORA-02019: connection description for remote database not found
  ```

Both problems have the same fix: run the statement from a temporary procedure
**owned by the link owner** and declared `authid definer`. A definer-rights
procedure runs with its owner's rights and name resolution, so the link is
created in, and resolved from, the owner's schema.

- Use `authid definer`, never `authid current_user`. Invoker rights run as the
  deployer and fail again.
- Roles are disabled in definer-rights procedures, so the owner needs direct
  grants of every privilege used: `CREATE PROCEDURE`, `CREATE DATABASE LINK`
  for Part A, and `CREATE MATERIALIZED VIEW` plus `CREATE TABLE` for Part B.

## Shared changeset shape

Write every changeset as three plain statements in one changeset, each
terminated by `/`:

1. `create or replace procedure <owner>.tmp_create_<name> ... authid definer`;
2. an anonymous block that calls the procedure;
3. `drop procedure <owner>.tmp_create_<name>`.

Do not wrap these statements in another anonymous block that creates, runs, or
drops the procedure through dynamic SQL, and do not add failure cleanup. If the
call fails, the changeset stops before the drop. Fix the cause and rerun the
changeset: `create or replace` recreates the procedure, and the drop runs after
a successful call.

When the procedure body contains a text literal, such as DDL for
`execute immediate`, quote it with `q'~...~'`. A `q'X...X'` literal ends at the
first closing delimiter followed by a single quote, so only that two-character
sequence matters. If the text contains `~'`, use the first of `^`, `!` or `|`
whose sequence (`^'`, `!'`, `|'`) does not appear in it. Avoid `#` (literals
such as `'#'`) and brackets such as `{}` (JSON literals end in `}'`).

## Part A: create the database link (custom changeset)

### Credentials

The link username and password never appear in the repository. They are
operating-system environment variables, exported before SQLcl starts
(manually, in a Docker container, or by a CI job). Liquibase replaces
`${REMOTE_USERNAME}` and `${REMOTE_PASSWORD}` in the changeset with their values:

```text
export REMOTE_USERNAME=<username>
export REMOTE_PASSWORD=<password>
```

Name the variables `<LINK>_USERNAME` and `<LINK>_PASSWORD`. Never write their
values into a changeset, script, or skill. An undefined variable stays in the
text as the literal `${NAME}`, which the changeset detects.

### Workflow

Apply this shape to new database link changesets. Do not rewrite existing link
changesets that use an older format unless the user asks.

1. Run `project stage add-custom -file-name <link>_db_link.sql` through the MCP
   SQLcl-command tool. Never create the file manually.
2. Keep the generated `-- liquibase formatted sql`, `-- changeset` and
   `-- sqlcl_snapshot` lines. Add `runOnChange:true` to the changeset line, and
   add the precondition lines shown below after the snapshot line.
3. Replace the placeholder body with the three statements below. Take the
   connect descriptor (host, port, service or SID) from the user. Do not guess it.
4. Confirm that the stage changelog includes the file before any changeset that
   uses the link (for example materialized views).

- `runOnChange:true` re-runs the changeset when the substituted values change.
- The precondition skips the changeset while `<LINK>_USERNAME` is undefined.
  `onFail:CONTINUE` leaves it unmarked, so it is retried on every deployment
  until the variable is provided.
- The procedure drops and recreates the link, so reruns are safe. It then tests
  the link with a remote `select` from `dual`; a failed test fails the changeset.
- Credentials reach the procedure as parameters, so the procedure text never
  contains them.

### Target shape

```sql
-- liquibase formatted sql
-- changeset SqlCl:<generated-id> stripComments:false logicalFilePath:<branch>\_custom\<link>_db_link.sql runOnChange:true
-- sqlcl_snapshot dist\releases\next\changes\<branch>\_custom\<link>_db_link.sql:null:null:custom
--preconditions onFail:CONTINUE
--precondition-sql-check expectedResult:0 SELECT count(*) from dual where '${<LINK>_USERNAME}' ='$'||'{'||'<LINK>_USERNAME'||'}'

/*
    (Re)creates the private database link <OWNER>.<LINK>. A private link can only
    be created by its owner, so a temporary definer-rights procedure owned by
    <OWNER> creates it: create the procedure, run it, drop it.
    Credentials come from the <LINK>_USERNAME and <LINK>_PASSWORD environment
    variables. If the run fails, fix the cause and rerun the changeset.
*/

create or replace procedure <owner>.tmp_create_<link>_db_link (
    p_username in varchar2,
    p_password in varchar2
) authid definer
is
    c_link        constant varchar2(128)  := '<LINK>';
    c_description constant varchar2(4000) :=
        '(DESCRIPTION=(ADDRESS_LIST=(ADDRESS=(PROTOCOL=TCP)(HOST=<host>)(PORT=<port>)))(CONNECT_DATA=(SERVICE_NAME=<service>)))';
    l_dummy varchar2(1);
begin
    if p_username is null or p_password is null or p_password like '$' || '{%' then
        raise_application_error(-20001, 'Database link ' || c_link || ': username and password are required');
    end if;
    if instr(p_password, '"') > 0 then
        raise_application_error(-20002, 'Database link ' || c_link || ': password must not contain double quotes');
    end if;

    -- db_domain may be appended to the link name, so match both <LINK> and <LINK>.<domain>
    for r in (select db_link from user_db_links where db_link = c_link or db_link like c_link || '.%') loop
        execute immediate 'drop database link ' || r.db_link;
    end loop;

    execute immediate 'create database link ' || c_link
        || ' connect to ' || dbms_assert.enquote_name(p_username)
        || ' identified by "' || p_password || '"'
        || ' using ' || dbms_assert.enquote_literal(c_description);

    begin
        execute immediate 'select dummy from dual@' || c_link into l_dummy;
        commit;
    exception
        when others then
            rollback;
            raise_application_error(-20003, 'Database link ' || c_link || ' was created but the connection test failed: ' || sqlerrm);
    end;

    begin
        dbms_session.close_database_link(c_link);
    exception
        when others then
            null; -- closing the session's link is housekeeping only; the test already passed
    end;
end;
/

begin
    <owner>.tmp_create_<link>_db_link(
        p_username => q'~${<LINK>_USERNAME}~',
        p_password => q'~${<LINK>_PASSWORD}~'
    );
end;
/

drop procedure <owner>.tmp_create_<link>_db_link
/
```

## Part B: changesets for objects that use the link

### Scope

- Run this after `project stage` and after
  [changeset splitting](changeset-splitting.md).
- Edit only staged changesets under `dist/releases/next/changes/<branch>/`.
  Keep the source file under `src/database/` as plain DDL; `project export`
  owns it.
- `project stage` generates a plain changeset again whenever the source changes,
  so "refresh my MV changesets" usually follows a new stage. Scan
  `dist/releases/next/changes/<branch>/<schema>/materialized_views/` (and any
  other DDL directory the user names) for statements that reference
  `@<link>`, and transform only those statements.
- Skip changesets that already use a `tmp_create_` procedure.
- Statements that do not resolve the link, such as `drop materialized view`,
  stay as they are.
- Do not edit changesets in a deployed release.

### Transformation

For each affected changeset:

1. Keep the generated header lines unchanged: `-- liquibase formatted sql`, the
   `-- changeset` line, and the `-- sqlcl_snapshot` line.
2. Remove the trailing `;` (or `/`) from the original DDL.
3. Replace the DDL with the three statements of the
   [shared changeset shape](#shared-changeset-shape). The procedure body runs the
   unchanged DDL with `execute immediate q'~...~'`.

### Target shape

```sql
-- liquibase formatted sql
-- changeset <AUTHOR>:<ID> stripComments:false logicalFilePath:<branch>\<schema>\materialized_views\<mv>.sql
-- sqlcl_snapshot src/database/<schema>/materialized_views/<mv>.sql:<old-hash>:<new-hash>:create

/*
    This materialized view selects through the private database link <OWNER>.<LINK>,
    which the deployer cannot see (ORA-02019). The DDL therefore runs inside a temporary
    definer-rights procedure owned by <OWNER>: create it, run it, drop it.
    If the build fails, fix the cause and rerun the changeset.
*/

create or replace procedure <owner>.tmp_create_<mv> authid definer
is
begin
    execute immediate q'~
create materialized view <owner>.<mv> (
    ...
)
    ...
as
    select ... from <table>@<link> ...
~';
end;
/

begin
    <owner>.tmp_create_<mv>;
end;
/

drop procedure <owner>.tmp_create_<mv>
/
```

## Verify

Dry-run each changeset through the MCP SQLcl-command tool before handing it
back:

1. Copy only the `create or replace procedure` and `drop procedure` statements
   into a scratch script under the repository `tmp/` folder.
2. Between them, query `all_errors` and `all_objects.status` for the procedure.
   SQLcl reports a compilation error only as a warning, so the `all_errors`
   query is required.
3. Run the script. This compiles the procedure without creating the link or
   building the object.
4. Confirm that no `<OWNER>.TMP_CREATE%` procedure is left in `all_objects`.

For Part A, also confirm that the precondition variable names match the
variables used in the call block.
