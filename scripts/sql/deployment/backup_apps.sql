--- Backup APEX apps under app ID +1000

set define on
set verify off
set feedback on
---set echo on

cd .

accept p_app_id prompt 'Enter Application ID to backup: '

! mkdir "tmp/backup"

apex export -applicationid &p_app_id. -dir tmp/backup 

set define on
prompt 'Backup completed. File located at tmp/backup/f&p_app_id..sql'

begin
   apex_application_install.set_application_id(1000+to_number(&p_app_id.)); 
   APEX_APPLICATION_INSTALL.GENERATE_OFFSET;
 end;
/ 

set feedback off
set echo off

@tmp/backup/f&p_app_id..sql 
prompt 'Application &p_app_id. imported as 1&p_app_id.'
