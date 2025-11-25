none

# 1. Working on A Feature ( Making Changes)

## 1.1. Git Tasks to Complete Before You Begin

Before you start making any changes to database objects make sure you
create a branch in Git. The branch should originate from the most recent
version of main branch. Run the following commands:

git checkout main git pull git checkout -b erp_fix_apexdev \#Replace
with your branch name

> Ideally branch names should be names of corresponded Jira tickets for
> easier Jira integratioin with Bitbucket

## 1.2. Development and Unit Testing Process

Proceed with development and unit testing using your favorite tool, for
example, SQL Developer, SQLcl, APEX, SQL Workshop, SQL Developer Web and
etc.

## 1.3. If New System Privileges Are Required for Application Schemas

If new system priveleges, roles, or table priveleges are required,
connect as super-user CLA_DEPLOYER and grant them to the schema

For example:

grant JAVA_ADMIN to cla_apex; grant cloud_user to cla_apex grant audit
system to cla_apex;

# 2. Export and Stage Changes

## 2.1. Export Standard Changes ( Packages, Tables and Etc.)

- Make sure you are staying in a root folder of your repository

- Connect to SQLcl as CLA_DEPLOYER ( connection name **proj_dev)**

- Export all database objects you chaged using -o option.

sql /nolog conn -name proj_dev proj export -o erp_emergency_event_util

Output of the command should look similar to the following:

PS C:\repo\cla-project\> sql /nolog SQLcl: Release 25.3 Production on
Thu Nov 20 12:55:39 2025 Copyright (c) 1982, 2025, Oracle. All rights
reserved. SQL\> conn -name proj_dev Connected. SQL\> proj export -o
erp_emergency_event_util The current connection
//10.194.2.158:1521/dev.privsubnet2reg.vcnclaylacy01.oraclevcn.com
CLA_DEPLOYER will be used for all operations \*\*\* PACKAGE_BODIES
\*\*\* \*\*\* PACKAGE_SPECS \*\*\* -------------------------------
PACKAGE_BODY 1 PACKAGE_SPEC 1 ------------------------------- Exported 2
objects Elapsed 10 sec

> Note: If you use SQLcl on Windows under Git Bash, use \`sql.exe
> //nolog\` instead of \`sql /nolog\`

## 2.2. Export APEX Application Changes

To export changed APEX applications, use the syntax APEX.\<app_id\> in
the export command, for example.

> **<span style="color: rgb(191,38,0);">Note:</span>** it’s important to
> DELETE APEX application files in ‘src’ before exporting, otherwise you
> may not see deleted pages and shated components until it’s too late…

!rm -fR src/database/cla_apex/apex_apps/f110 proj export -o APEX.110

The output should look similar to the following:

SQL\> proj export -o APEX.110 The current connection
//10.194.2.158:1521/dev.privsubnet2reg.vcnclaylacy01.oraclevcn.com
CLA_DEPLOYER will be used for all operations \*\*\* APEX_APPLICATIONS
\*\*\* Exporting Workspace CLA_INTERNAL - application 110:Tactical
Emergency Response Program -------------------------------
APEX_APPLICATION 1 ------------------------------- Exported 1 objects
Elapsed 20 sec SQL\>

**Carefully review generated files in the** `src` **folder to make sure
they contain ONLY your changes and ALL your changes**

## 2.3.<span style="color: rgb(255,86,48);"> Tricky: </span>Export Changes In Grants To Application Schema

> **<span style="color: rgb(255,86,48);">Note:</span>** This is a bit
> tricky ( actually it’s really tricky) due to several implementation
> bugs in SQLcl Project. Fortunately, this task is not a part of
> ordinary change.

- Login as Schema user, i.e. CLA_APEX and NOT as CLA_DEPLOYER

- Open `.dbtools/filters/project.filters` for edit and uncomment line
  `export_type in ('USER','USER_SYS_PRIVS','USER_ROLE_PRIVS'),`

- Run “full” export:

conn -name dev_apex proj export

- Export will generate files
  `src/database/sys/object_grants/user_role_privs.sql` and
  `src/database/sys/object_grants/user_sys_privs.sql`

- **<span style="color: rgb(255,86,48);">Attention! When you open the
  files in VS Code, you will notice that new grants for the current user
  are added and grants for other users are REMOVED. This is a very
  severe bug with SQLcl Project at the time of writing.</span>**

<!-- -->

- Manually reintroduce lost changes to the files. Sometimes it’s
  convenient to do in VS Code using the arrow between old and new
  versions, but be careful:

<!-- -->

- Make sure that the grant files only contain your changes

<!-- -->

- **Revert Changes to Filters file** `.dbtools/filters/project.filters`
  before committing in Git.

## 2.4. Stage Changes

You are ready to stage changes when the following actions have been
completed:

- All changed database objects (tables, views, triggers, constraints,
  packages) have been exported

- All changed APEX applications have been exported

- All changed grants and privileges have been exported

- The following changes will be added AFTER Stage command:

  - Custom /DML Changes

  - ORDS Handlers Changes ( at least at the time of writing)

To do staging:

git add . git commit -m 'ready to stage' sql /nolog conn -name proj_dev
proj stage

Output on the process will look like the following. Please note the
warnings “**The hash value of the file user_role_privs.sql was incorrect
and has been automatically adjusted**” . This is a result of our manual
adjsutment of these files. It’s expected

SQL\> proj stage Stage is Comparing: Old Branch refs/heads/main New
Branch refs/heads/erp_fix_apexdev WARN: The following files were
updated: The hash value of the file user_role_privs.sql was incorrect
and has been automatically adjusted The hash value of the file
user_sys_privs.sql was incorrect and has been automatically adjusted
Stage processesing completed, please review and commit your changes to
repository

All information below “**Stage processesing completed**” line is pretty
much useless.

Review the changes in VS Code. Verify that you only have the changes
that you made.

> Note: You may note changes to “ORDS” that you did not make.
> **<span style="color: rgb(255,86,48);">This is another bug with SQLcl
> . </span>** You should get rid of these changes either by pressing
> “Disacard” button in VS Code or running Git Command
>
> git restore --source=main --worktree --staged -- dist/releases/ords

> **Note:** If you find it more convinient, you may run git commands
> from SQLcl using **!** syntax. However, in this case run `pwd` first
> to verify that SQLcl is in repo root folder
>
> pwd !git add.

## 2.5. Add DML and Other Custom Changes

If you need to add DML or any other custom files to your feature, it’s
time to do it now with ‘stage add-custom’ command.

proj stage add-custom -file-name test.sql

The most common custom changes:

1.  DML on “fixed” tables, for example, insert 15 invoice statuses into
    INVOICE_STATUS table

2.  Handle objects that SQLcl project does not handle natively, for
    example:

    1.  Run Alter System

    2.  Create/Drop APEX Workspace

    3.  Create/Drop Scheduled Jobs, AQ Tables, Refresh Materialized
        Views

    4.  Stop/Start Jobs and APEX Automations

    5.  … and much more…

After running add-custom command above, open the file
`dist/releases/next/changes/<your_branch>/_custom/test.sql` for edit and
add your code after LB header, so for example it looks like this:

-- liquibase formatted sql -- changeset SqlCl:1763669390933
stripComments:false logicalFilePath:erp_fix_apexdev\\custom\test.sql --
sqlcl_snapshot
dist\releases\next\changes\erp_fix_apexdev\\custom\test.sql:null:null:custom
Prompt "Testing..." begin null; end; /

## 2.7. <span style="color: rgb(255,86,48);">Tricky</span>:Add ORDS Changes

SQLcl provides built-in inetrface to manage ORDs schema, **however this
interface lacks granularity and deals with the entire schema.**

In reality, developers usually make changes to a module, test it and
want to deploy this module only to production. Your development
environment may include other multiple modules which are in WIP or POC
state, so deploying the entire schema is very rare an option...

To incorporate deployment of ORDS module changes into your feature,
follow the procedure and example available in the file
`scripts/sql/deployment/deploy_ords_module.sql`:

1.  Create a custom script to export ORDS module definition

proj stage add-custom -file-name ord_tracerp_module -- replace by your
module name

2.  Run the script below as schema owner CLA_APEX or CLA_PUBLIC (NOT as
    CLA_DEPLOYER!!!!) to export ORDS module definition

SELECT REGEXP_REPLACE( ords_metadata.ords_export.export_module (
p_module_name =\> u.name, p_include_enable_schema =\> false ,
p_include_privs =\> true , p_privs_with_other_mod_refs =\> true,
p_export_date =\> false ), 'ORDS\\(\[^\\\]\*\\)', 'ORDS_ADMIN.\1
p_schema =\> '''\|\|user\|\|''', ', 1, 0, 'n' )\|\|' / ' stmt FROM
USER_ORDS_MODULES u where u.name = 'claylacy.tacerp' --- specify your
module name here /

3.  APPEND the output to the file created in step 1

## 2.9. Split Statements in DDL File

**Another limitation of SQLcl is that it does not split ALTER TABLE and
other table-related statements in a changeset file.**

For, example, if you have multiple changes in CLA_AIRCRAFT table, you
file
`dist/releases/next/changes/dev-02/cla_apex/tables/cla_aircraft.sql `

will look like this:

-- liquibase formatted sql -- sqlcl_snapshot
src/database/cla_apex/tables/cla_aircraft.sql:08bee489420289da19c387e5b924e0e21acc0faa:f6b3abb88fff315ad9e845989ec24ed6b54d31a3:alter
-- changeset CLA_APEX:1761764378736 stripComments:false
logicalFilePath:dev-02\cla_apex\tables\cla_aircraft.sql alter table
cla_apex.cla_aircraft drop (fl3xx_live); alter table
cla_apex.cla_aircraft add ( adult_critical_care number(1, 0),
aviapages_aircraft_id number, aviapages_aircraft_type_id number,
year_of_production number ); alter table cla_apex.cla_aircraft add
constraint make_model_serial_uk2 unique (aviapages_aircraft_type_id,
serial_number) using index enable; alter table cla_apex.cla_aircraft add
constraint registration_uk1 unique (registration) using index enable;

This file should be manually edited to move each DDL statement in its
own changeset, the resulting file should look like the following:

-- liquibase formatted sql -- sqlcl_snapshot
src/database/cla_apex/tables/cla_aircraft.sql:08bee489420289da19c387e5b924e0e21acc0faa:f6b3abb88fff315ad9e845989ec24ed6b54d31a3:alter
-- changeset CLA_APEX:1761764378736.1 stripComments:false
logicalFilePath:dev-02\cla_apex\tables\cla_aircraft.sql alter table
cla_apex.cla_aircraft drop (fl3xx_live); -- changeset
CLA_APEX:1761764378736.2 stripComments:false
logicalFilePath:dev-02\cla_apex\tables\cla_aircraft.sql alter table
cla_apex.cla_aircraft add ( adult_critical_care number(1, 0),
aviapages_aircraft_id number, aviapages_aircraft_type_id number,
year_of_production number ); -- changeset CLA_APEX:1761764378736.3
stripComments:false
logicalFilePath:dev-02\cla_apex\tables\cla_aircraft.sql alter table
cla_apex.cla_aircraft add constraint make_model_serial_uk2 unique
(aviapages_aircraft_type_id, serial_number) using index enable; --
changeset CLA_APEX:1761764378736.4 stripComments:false
logicalFilePath:dev-02\cla_apex\tables\cla_aircraft.sql alter table
cla_apex.cla_aircraft add constraint registration_uk1 unique
(registration) using index enable;

I.e. one line

**-- changeset CLA_APEX:1761764378736 stripComments:false
logicalFilePath:dev-02\cla_apex\tables\cla_aircraft.sql**

is replaced by four lines

**-- changeset
CLA_APEX:1761764378736.<span style="color: rgb(191,38,0);">\[1-4\]</span>
stripComments:false
logicalFilePath:dev-02\cla_apex\tables\cla_aircraft.sql**

That allows the installation process to become restartable regradless at
what statement the process fails

##  2.8. <span style="color: rgb(191,38,0);">Tricky:</span> Re-Staging

If you discovered that you need to do some changes to SRC ( for example,
if you forgot to include an object, you need to change the package, or
last minute in changing grands) you will have to do re-staging.
**Unfortunately, SQLcl Project does a terrible job with incremental
staging and re-staging.**

There are two situations:

1.  **You did not do too many manual changes to your feature in DIST**

In this case, the best option would be discarding chages under `dist` in
Git and do `project stage`

For example, we granted above two new priveleges to CLA_APEX - Turns out
it was a mistake. Now the privileges have been revoked in DEV and we
need to update our feature branch:

- Fist, we restore grants files from main:

git restore --source=main --worktree --staged
src/database/sys/object_grants/user_role_privs.sql git restore
--source=main --worktree --staged
src/database/sys/object_grants/user_sys_privs.sql

- Now we fully discard changes in `dist`

> Notes: You may find more convinient to go it with VS Code Discard
> button

git restore --source=main --worktree --staged dist/releases/ git restore
--staged dist/releases/ git clean -fd dist/releases/

- Now commit the reverted changes in SRC and stage again

!git commit -m 'removed wrong grants' conn -name proj_dev proj stage

- As annoying as it is, fake ORDS changes are generated and need to be
  removed

git restore --source=main --worktree --staged -- dist/releases/ords

Now you have a clean updated dist folder which is ready for deployment

2.  **You did sizable changes in DIST Folder**

Unfortunately, SQLcl Project does not do a good job here. If you want to
re-stage after you have made significant changes, you need to follow
these steps:

- Commit or at least stage in Git your current changes, so you can
  easily see the difference re-staging will introduce

git add dist/ \# Optionally git commit -m "before re-staging"

- Run stage command again

project stage

- In VS Code in Changes **<span style="color: rgb(255,86,48);">very
  careful review all changed files and make case-by-case decision if you
  wan to:</span>**

  - Accept new changes

  - Discard new changes

  - Merge changes

- One of the files wich **always be** changed at re-staging is
  `dist/releases/next/changes/<feature>/stage.changelog.xml` **Always
  open this file in VS Code Changes view and analyse the differences.**

As you can see, in this example `project stage` just added the same
files to this file twice. In this case, the changes to this file can
simply be discarded; however, more often you would need to merge old and
new changes in this file manually.

# 3. Test Deployment Scripts

To test deployment scripts you need to run them against VM database.

- You can discover multiple issues during deployment and may need to
  rerun it several times.

- If you ran into a problem you can fix it and continue. However, to
  verify your fix you should restore VM to a restore point and try to
  run entire script error free.

- Use Helper script `dist/install_vm.sql` to try your deployment on VM

cd . conn -name proj_vm prompt "Dropping restore point before
installation if exists" begin execute immediate 'drop restore point
before_installation'; exception when others then if sqlcode != -1918
then raise; end if; end; / prompt "Creating restore point before
installation" create restore point before_installation; @install

- To run the script, make sure you start from dist folder:

cd dist @dist/install_vm.sql

- If you have any erorrs, run the script `@install.sql` not
  `install_vm.sql`until you have a clean run install.

- If possible, connect to VM in SQL Developer, review and unit test your
  changes.

**When you are done with testing, reset VM to the restore point.Run**
`scripts\sql\deployment\vm_flashback.sql`

**At this point you tested your deployment against the VM database and
reset the VM to he state of the main branch.**

# 4. Submit and Merge PR

## 4.1. Submit PR

Now, you know that your code is deployable, it’s time to submit a PR and
get reviewed and it approved by your peers!

To submit a PR:

git add . git commit -m 'ready for review' git push --set-upstream
origin erp_fix_apexdev \#replace with your branch name

Bitbucket will create a pull request for you and send you back a URL.
Follow the URL:

git push --set-upstream origin erp_fix_apexdev Enumerating objects: 77,
done. Counting objects: 100% (77/77), done. Delta compression using up
to 16 threads Compressing objects: 100% (43/43), done. Writing objects:
100% (49/49), 32.48 KiB \| 665.00 KiB/s, done. Total 49 (delta 26),
reused 0 (delta 0), pack-reused 0 (from 0) remote: remote: Create pull
request for erp_fix_apexdev: remote:
https://bitbucket.org/cla-apex/cla-project/pull-requests/new?source=erp_fix_apexdev&t=1
remote: To bitbucket.org:cla-apex/cla-project.git \* \[new branch\]
erp_fix_apexdev -\> erp_fix_apexdev branch 'erp_fix_apexdev' set up to
track 'origin/erp_fix_apexdev'.

In this case the url to follow was
<https://bitbucket.org/cla-apex/cla-project/pull-requests/new?source=erp_fix_apexdev&t=1>

> **Carefully review all the changes in bitbucket, make sure you
> understand every change. When done with the review:**
>
> 1.  **Click “Create pull request” buton**
>
> 2.  Assing the reviewer

## 4.2. Approve and Merge PR

Work with the reviewer to make sure the feature is approved and merged.
To merge PR open it and click Merge button.

## 4.3. Pull Main Branch

After PR is approved, it’s critical to switch branch to main and pull
main before proceeding to all steps below

git checkout main git pull

# 5. <span style="color: rgb(255,86,48);">Optional: </span>Build Deployment Articact

After the feature is merged, it’s ready to be deployed to TEST.

**<u>Optionally</u>** you can build an artifact to support the
deployment.

project gen-artifact -name erp_fix_apexdev -version 25.3 -format zip
-verbose

successfull command output will look the followinfg:

... ile : C:\repo\cla-project\dist\sqlcl-lb-1763754424655.log file :
C:\repo\cla-project\dist\sqlcl-lb-1763754930069.log file :
C:\repo\cla-project\dist\utils\enable_automations.sql file :
C:\repo\cla-project\dist\utils\prechecks.sql file :
C:\repo\cla-project\dist\utils\recompile.sql Your artifact has been
generated erp_fix_apexdev-25.3.zip

> **Note**: Building atrifact is mandatory if deployment to Test is
> carried out by a DBA or CI/CD Pipeline process.
>
> In case the deployment is carried out by developer, the articact is
> not required.

# 6. Deploy to Test

## 6.1. Deployment By Developer ( No Artifact)

To deployment to test by the developer, it’s enoug to run the following
command in SQLcl:

conn -name proj_test show conn --- Verify pwd -- Veriy if current floder
is dist. If not: cd dist @install

During the deployment a log file `dist/sqlcl-lb-<some-id>log` will be
generated and can be reviewed later for troubleshooting.

## 6.2. Deployment With Artifact

conn -name proj_test project deploy -file
artifact/erp_fix_apexdev-25.3.zip -verbose

> **Note:** If artifact has nothing to do, it fails with ugly Java
> error:
>
> tarting the migration... Installing/updating schemas --Starting
> Liquibase at 2025-11-21T16:06:36.141710600 using Java 17.0.13 (version
> 4.30.0 \#0 built at 2025-04-01 10:24+0000) Running Changeset:
> dev-01/\_custom/ams_config_dml.sql::1761249915279::SqlCl UPDATE
> SUMMARY Run: 1 Previously run: 2572 Filtered out: 0
> ------------------------------- Total change sets: 2573 Liquibase:
> Update has been successful. Rows affected: 0 Null Pointer please log a
> bug. java.lang.NullPointerException: Cannot invoke
> "java.io.File.getName()" because the return value of
> "oracle.dbtools.raptor.liquibase.util.LbFileUtils.getLog()" is null at
> oracle.dbtools.raptor.scriptrunner.commands.liquibase.LbCommand.write_success(LbCommand.java:475)
> at
> oracle.dbtools.raptor.scriptrunner.commands.liquibase.LbCommand.handleEvent(LbCommand.java:382)
> at
> oracle.dbtools.raptor.newscriptrunner.CommandRegistry.fireListeners(CommandRegistry.java:454)
> at
> oracle.dbtools.raptor.newscriptrunner.ScriptRunner.lambda\$run\$0(ScriptRunner.java:241)
> at
> oracle.dbtools.raptor.newscriptrunner.ScriptRunnerContext.runWithStoredContext(ScriptRunnerContext.java:837)

# 7. Conduct UAT

Well, this is up to the cleint

**Important:** If issues are found during UAT testing, at your
discreptrion:

- You can start a new branch in Git ( **Highly recommended in most cases
  !!!!)**

- Check out current feature branch and continue to working( Only
  recommended for small changes like adding a custom file or rebuilding
  a package)

In either afer a UAT fix is apprived and tested in TEST, merge changes
to main.

If you have fixed UAT issue in test, please backfill Dev ( see
https://claviation.atlassian.net/wiki/spaces/OA/pages/2562097153/5.+Hot+Fix+Deployment
for details )

# 8. Build a Release

- Release is built when all changes that need to go to Prod have passed
  UAT in Test

- There are NO changes in Test ( and merged into the main branch that
  are currently undergoing testing)

To build a release ( Replace 25.3. by your release number):

conn -name proj_test --- Can be also dev, prod, or vm, goes not matter
git checkout main git pull --- you can build release in main to save
time, it's OK... proj release -version 25.3 -v git add . git commit -m
'release 25.3' git tag 25.3 git push

# 9. Deploy to Prod

## 9.1. Avoid Surprises

To avoid any surprises, what would be run in Production, before
proceeding with a real update, **always** run `LB STATUS`:

conn -name proj_prod lb status -changelog-file
releases/main.changelog.xml

It produces the following output:

SQL\> lb status -changelog-file releases/main.changelog.xml --Starting
Liquibase at 2025-11-21T16:38:05.487693200 using Java 17.0.13 (version
4.30.0 \#0 built at 2025-04-01 10:24+0000) 4 changesets have not been
applied to
CLA_DEPLOYER@jdbc:oracle:thin:@//10.194.2.167:1521/pdb01.privsubnet2reg.vcnclaylacy01.oraclevcn.com
dev-01/\_custom/ams_config_dml.sql::1761249915279::SqlCl
erp_fix_apexdev/cla_apex/package_specs/erp_emergency_event_util.sql::1763752587080::CLA_APEX
erp_fix_apexdev/cla_apex/package_bodies/erp_emergency_event_util.sql::1763752586636::CLA_APEX
releases/apex/f110/f110.xml::INSTALL_110::SQLCL-Generated Operation
completed successfully.

Make sure you recognize all changes ( and the most important - all APEX
apps that are going to be deployed)

## 9.2. Identify Production Drift

Follow
<https://claviation.atlassian.net/wiki/spaces/OA/pages/2561638402/6.+Mitigating+Production+Drift?atlOrigin=eyJpIjoiZDljMjc4OTEzNWE0NDgyMmIyOTdiYTc0OGNlMGY5OTUiLCJwIjoiYyJ9>
to identify any drift in objects you are about to deploy

## 9.3. GO!

Follow the same procedures as for
<https://claviation.atlassian.net/wiki/spaces/OA/pages/edit-v2/2561867784#6.-Deploy-to-Test>

# 10. Taking Care of Unexpected

Even a perfectly tested deployment sometimes fails in Production. There
are two strategies to deal with that:

1.  If your system supports it, incorporate into your deployment ( or
    run before your deployment) a `CREATE RESTORE POINT` command:

create restore point before_installation;

If deployment fails, you may ask a DBA to flashback your database ot
this restore point:

FLASHBACK PLUGGABLE DATABASE FREEPDB1 TO RESTORE POINT TEST

> Note: Fleashback Pluggable Database feature is not supported in Oracle
> Standard

2.  If you do not have the flashback option, you will need to finish
    deployment, otherwise your system will be in an inconsistent state.

- In case of changeset failing, investigate and eliminate the root
  cause. For example, if you fail to create a unique constratint, delete
  duplicate records and rerun the installation

- In you are trying to create a unique constraint that already exists,
  run the following command to mark the last failed changeset as “RUN”
  and proceed with installation.

liquibase mark-next-changeset-ran -changelog-file
releases/main.changelog.xml

# 

# 

## 
