-- =====================================================================
-- APEX import timing test: APEXLANG vs SQL, across increasing page counts
-- =====================================================================
-- DEV ONLY. Repeatedly reinstalls application &test_app_id. Never run against prod.
-- Requires the test_al_load / test_sql_load aliases
-- (scripts/xml/stel-timing-aliases.xml) to be registered in SQLcl.
--
-- Usage (already connected, from project root):
--   @scripts/sql/apex_timing_test.sql

set define on
set verify off
set feedback on
--set echo on
set termout on

define test_app_id=106
define test_app_alias=demo1
define test_al_dir=src/database/demo1/apex_apps/f&test_app_id/&test_app_alias
define test_sql_dir=src/database/demo1/apex_apps/f&test_app_id

-- Logging is handled externally by run_apex_timing_test.sh, which redirects
-- this whole SQLcl process's stdout/stderr to a log file. `spool` is not used
-- here because it misses output from `!` shell-outs (e.g. clone_apex_page.py).


prompt ================================================================
prompt Confirming test variables
prompt ================================================================
prompt test_app_id    = &test_app_id
prompt test_app_alias = &test_app_alias
prompt test_al_dir    = &test_al_dir
prompt test_sql_dir   = &test_sql_dir

@@apex_timing_test_step.sql 0
@@apex_timing_test_step.sql 10
@@apex_timing_test_step.sql 50
@@apex_timing_test_step.sql 100
@@apex_timing_test_step.sql 200
@@apex_timing_test_step.sql 300

prompt
prompt All cycles complete. Review the log above.
