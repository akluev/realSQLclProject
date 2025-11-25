-- SQL*Plus script to create and save DBA connections for CLA databases

set define on
set feedback on
set echo on
set termout on


define VM_PASSWORD=oracle



connect sys/&VM_PASSWORD@//localhost:1521/free as sysdba

connect -save vm_cdb -savepwd -replace


connect sys/&VM_PASSWORD@//localhost:1521/freepdb1 as sysdba

connect -save vm_sys -savepwd -replace


connect cla_deployer/&VM_PASSWORD@//localhost:1521/freepdb1

connect -save proj_vm -savepwd -replace


connmgr list
