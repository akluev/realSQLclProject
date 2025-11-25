--- Flashback FREEPDB1 to before installation state

set echo on
set termout on
set feedback on
conn -name vm_sys 

ALTER PLUGGABLE DATABASE FREEPDB1  CLOSE IMMEDIATE;

FLASHBACK PLUGGABLE DATABASE FREEPDB1 TO RESTORE POINT before_installation;

ALTER PLUGGABLE DATABASE FREEPDB1  OPEN RESETLOGS;
