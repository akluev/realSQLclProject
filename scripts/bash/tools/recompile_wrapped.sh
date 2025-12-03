#!/bin/bash

# This script recompiles wrapped PL/SQL code to include schema name prefixes.
#find src/database -type f -path "*/package_bodies/*" |xargs -i  grep -ilE "PACKAGE BODY.*wrapped" {}|sed 's|^|@|' > tmp/recompile_wrapped.sql

cd dist

find . -type f -path "*/package_bodies/*" |xargs -i  grep -ilE "PACKAGE BODY.*wrapped" {}|sed 's|^|@|' > ../tmp/recompile_wrapped.sql

 #now run the script against the database with SQCcl