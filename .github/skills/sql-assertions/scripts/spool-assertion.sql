-- Spools DEFINITION_SQL of one assertion to src/ext/<owner>/assertions/tmp/<name>-raw.sql.
-- Run as one MCP sqlcl_run call:
--   @<skill>/scripts/spool-assertion.sql <USER|DBA> <OWNER> <ASSERTION_NAME> <absolute project root>
-- USER reads USER_ASSERTIONS and requires <OWNER> to be the session user; DBA reads DBA_ASSERTIONS filtered by OWNER.
-- Writes nothing else and changes no database state. export-assertion.sh processes the spooled file.
set define on
set verify off
set feedback off
set heading off
set pagesize 0
set sqlformat default
set long 1000000
set longchunksize 1000000
set trimspool on
set linesize 32767
column raw_path new_value raw_path noprint
column src_view new_value src_view noprint
column owner_pred new_value owner_pred noprint
select replace('&4', '\', '/') || '/src/ext/' || lower('&2') || '/assertions/tmp/' || lower('&3') || '-raw.sql' as raw_path,
       case upper('&1') when 'USER' then 'user_assertions' when 'DBA' then 'dba_assertions' else 'invalid_mode_use_user_or_dba' end as src_view,
       case upper('&1') when 'USER' then 'user' else 'owner' end as owner_pred
  from dual;
spool "&raw_path" replace
select definition_sql
  from &src_view
 where &owner_pred = '&2'
   and assertion_name = '&3';
spool off
undefine 1 2 3 4 raw_path src_view owner_pred
