-- =====================================================================
-- APEXlang validation timing test without a database connection
-- =====================================================================
-- The step script creates and removes cloned page files in the test project.
--
-- Usage (from a disconnected SQLcl session in the project root):
--   @scripts/sql/apex_validate_nolog.sql 0 300 600

set define on
set verify off
set feedback on
--set echo on
set termout on

define test_app_id=106
define test_app_alias=demo1
define test_al_dir=src/database/demo1/apex_apps/f&test_app_id/&test_app_alias
define test_sql_dir=src/database/demo1/apex_apps/f&test_app_id

-- Logging is handled externally by run_apex_validate_nolog.sh, which redirects
-- this whole SQLcl process's stdout/stderr to a log file. `spool` is not used
-- here because it misses output from `!` shell-outs (e.g. clone_apex_page.py).

define step1=&1
define step2=&2
define step3=&3


prompt ================================================================
prompt Confirming test variables
prompt ================================================================
prompt test_app_id    = &test_app_id
prompt test_app_alias = &test_app_alias
prompt test_al_dir    = &test_al_dir
prompt test_sql_dir   = &test_sql_dir


prompt Validation 3 times for &step1 pages

@@apex_validate_nolog_step.sql &test_al_dir &step1
@@apex_validate_nolog_step.sql &test_al_dir &step1
@@apex_validate_nolog_step.sql &test_al_dir &step1


prompt Validation 3 times for &step2 pages

@@apex_validate_nolog_step.sql &test_al_dir &step2
@@apex_validate_nolog_step.sql &test_al_dir &step2
@@apex_validate_nolog_step.sql &test_al_dir &step2


prompt Validation 3 times for &step3 pages

@@apex_validate_nolog_step.sql &test_al_dir &step3
@@apex_validate_nolog_step.sql &test_al_dir &step3
@@apex_validate_nolog_step.sql &test_al_dir &step3


prompt
prompt All cycles complete. Review the log above.
