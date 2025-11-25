--- Reest all application schemams and workspaces in VM to a known state
set echo on
set termout on
set feedback on

whenever sqlerror exit sql.sqlcode;

conn -name vm_sys 

whenever sqlerror continue;

prompt "Dropping restore point before installation if exists"
begin
    execute immediate 'drop restore point before_installation';
exception
    when others then
        if sqlcode != -1918 then
            raise;
        end if;
end;
/
prompt "Creating restore point before installation"
create restore point before_installation;   

BEGIN
 for rec in ( select workspace from apex_workspaces where workspace in ('CLA_PUBLIC','CLA_INTERNAL') ) loop
    APEX_INSTANCE_ADMIN.REMOVE_WORKSPACE(rec.workspace,'N','N');
 end loop;
END;
/


drop user if exists cla_public cascade;
drop user if exists cla_utilities cascade;
drop user if exists cla_apex cascade;
drop user if exists cla_deployer cascade;

@@create_cla_deployer.sql 

alter user cla_deployer identified by "oracle" account unlock;