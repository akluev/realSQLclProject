-- Drop everything the test project installs: APEX workspace, ORDS definitions,
-- Liquibase changelog table and the schema.
-- Usage (from the test project folder): sql -nolog @drop_all.sql <connection_name> <schema_name> <workspace_name>
whenever sqlerror exit sql.sqlcode
whenever oserror exit failure
set termout on
set serveroutput on
set verify off
set define on

-- connection_name: saved SQLcl connection of the installer (conn -name)
-- schema_name:     project schema
-- workspace_name:  APEX workspace
define connection_name = "&1"
define schema_name     = "&2"
define workspace_name  = "&3"

conn -name &connection_name

-- The baseline maps the schema to more than one workspace (test 023): drop all of them
prompt "Dropping workspace &workspace_name and every other workspace of &schema_name"
begin
  for rec in (select workspace from apex_workspaces where workspace = upper('&workspace_name')
              union
              select workspace_name from apex_workspace_schemas where schema = upper('&schema_name')) loop
    apex_instance_admin.remove_workspace(rec.workspace, 'Y', 'N');
    dbms_output.put_line('Workspace dropped ' || rec.workspace);
  end loop;
  commit;
end;
/

-- ORDS metadata survives DROP USER CASCADE, and installing the schema-connection ORDS export
-- as the installer REST-enables the installer itself (regression test 018): drop both.
prompt "Dropping ORDS definitions of &schema_name and the installer"
begin
  for rec in (select parsing_schema from ords_metadata.ords_schemas
              where parsing_schema in (upper('&schema_name'), user)) loop
    ords_admin.drop_rest_for_schema(p_schema => rec.parsing_schema);
    dbms_output.put_line('ORDS dropped ' || rec.parsing_schema);
  end loop;
  commit;
end;
/

prompt "Dropping the Liquibase changelog"
drop table if exists databasechangelog;

prompt "Dropping the Liquibase changelog actions"
drop table if exists databasechangelog_actions;

prompt "Dropping user &schema_name"
drop user if exists &schema_name cascade;

prompt "Dropped"
exit
