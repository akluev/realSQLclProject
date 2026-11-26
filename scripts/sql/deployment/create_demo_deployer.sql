--- Run as SYS to create the CLA Deployer user and grant necessary privileges ---

create user if not exists DEMO_DEPLOYER no authentication
/

grant dba to DEMO_DEPLOYER
/

grant connect to DEMO_DEPLOYER
/

grant APEX_ADMINISTRATOR_ROLE  to DEMO_DEPLOYER with admin option
/

grant execute on sys.dbms_crypto to DEMO_DEPLOYER with grant option;

grant execute on sys.dbms_session  to DEMO_DEPLOYER with grant option;

grant execute on sys.javascript to DEMO_DEPLOYER with grant option;



