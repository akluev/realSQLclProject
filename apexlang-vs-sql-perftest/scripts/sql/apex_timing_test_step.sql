-- Run one APEX import timing cycle for the requested number of extra pages.
-- Called by apex_timing_test.sql; shared test_* variables must already be defined.

set define on
define test_extra_pages=&1

prompt
prompt ################################################################
prompt # CYCLE: extra pages = &test_extra_pages
prompt ################################################################

prompt ### STEP: generate extra pages ###
! python scripts/apex/clone_apex_page.py 6 &test_extra_pages

prompt ### STEP: warm-up APEXLANG import ###
set define on
test_al_load &test_al_dir

prompt ### STEP: export SQL file ###
set define on
apex export -applicationid &test_app_id -exptype SQL -dir &test_sql_dir -overwrite-files -force

prompt ### STEP: warm-up SQL import ###
set define on
test_sql_load &test_sql_dir/f&test_app_id

prompt ### STEP: measured set 1 (APEXLANG, then SQL) ###
set define on
test_al_load &test_al_dir
set define on
test_sql_load &test_sql_dir/f&test_app_id

prompt ### STEP: measured set 2 (SQL, then APEXLANG - reversed order) ###
set define on
test_sql_load &test_sql_dir/f&test_app_id
set define on
test_al_load &test_al_dir

undefine test_extra_pages