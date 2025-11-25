--- Run as SYS to create the CLA Deployer user and grant necessary privileges ---

create user if not exists cla_DEPLOYER no authentication 
/

grant dba to cla_DEPLOYER
/

grant connect to cla_DEPLOYER
/

grant APEX_ADMINISTRATOR_ROLE  to cla_DEPLOYER with admin option
/

grant execute on sys.dbms_crypto to cla_DEPLOYER with grant option;

grant execute on sys.dbms_session  to cla_DEPLOYER with grant option;

grant execute on sys.javascript to cla_DEPLOYER with grant option;



