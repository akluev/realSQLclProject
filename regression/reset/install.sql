-- Install the test project from dist (Liquibase). Everything the baseline needs, including
-- APEX workspace settings, is in its changesets.
-- Usage (from the test project folder): sql -nolog @install.sql <connection_name>
whenever sqlerror exit sql.sqlcode
whenever oserror exit failure
set termout on
set verify off
set define on

-- connection_name: saved SQLcl connection of the installer (conn -name)
define connection_name = "&1"

conn -name &connection_name

prompt "Installing dist/install.sql"
cd dist
@install
cd ..

prompt "Installed"
exit
