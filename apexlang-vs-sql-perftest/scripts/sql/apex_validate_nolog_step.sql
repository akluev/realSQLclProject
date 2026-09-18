set define on
set verify off
set timing off
define apexlang_path=&1
define extra_pages=&2
prompt Add &extra_pages pages
! python scripts/apex/clone_apex_page.py 6 &extra_pages


prompt Validating APEXlang application from &apexlang_path. ...

! bash -c "date +%s >/tmp/start_time"
apex validate -input &apexlang_path.
! bash -c "echo \"Elapsed $(($(date +%s) - $(cat /tmp/start_time))) seconds\"; rm /tmp/start_time"

