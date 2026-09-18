-- Trace one APEX application import in the current SQLcl session.
-- Usage:
--   @scripts/sql/apex_import_trace.sql APEXLANG
--   @scripts/sql/apex_import_trace.sql SQL
-- Reconnect between invocations so each method has a separate session.

set define on
set verify off
set feedback on
set termout on

define trace_method=&1
define test_app_id=106
define test_app_alias=demo1
define test_page_count=214
define test_al_dir=src/database/demo1/apex_apps/f&test_app_id/&test_app_alias
define test_sql_dir=src/database/demo1/apex_apps/f&test_app_id

column trace_identifier new_value trace_identifier noprint
select 'APEX' || '&test_app_id' || '_' || upper('&trace_method') || '_'
       || '&test_page_count' || 'P_' || to_char(sysdate, 'YYYYMMDD_HH24MISS')
       as trace_identifier
  from dual;

column import_command new_value import_command noprint
select case upper('&trace_method')
           when 'APEXLANG' then 'test_al_load &test_al_dir'
           when 'SQL' then 'test_sql_load &test_sql_dir/f&test_app_id'
           else 'prompt ERROR: method must be APEXLANG or SQL'
       end as import_command
  from dual;

prompt Trace identifier: &trace_identifier
alter session set tracefile_identifier = '&trace_identifier';

begin
    dbms_monitor.session_trace_enable(
        waits => true,
        binds => false
    );
end;
/

&import_command

set define on
begin
    dbms_monitor.session_trace_disable;
end;
/

set linesize 160

column trace_file format a160
select value as trace_file
  from v$diag_info
 where name = 'Default Trace File';

undefine trace_method
undefine trace_identifier
undefine import_command
