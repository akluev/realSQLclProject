# Object export

Use this workflow to synchronize database objects or APEX applications back to source files.

## Version check

Use the SQLcl MCP command tool to run `version` or `define _sqlplus_release` before every export.

- SQLcl 26.1 or later (`_sqlplus_release >= 2601000000`): run the export through MCP.
- Earlier or indeterminate version: stop and report that SQLcl 26.1 or later is required. Do not offer or invoke a local SQLcl fallback.

## Targeted database-object export

1. Resolve the changed database objects.
2. Run `project export -o <comma-separated-object-list>` asynchronously through MCP.
3. Poll the returned request until it reaches a terminal state.
4. Report success or the complete failure output.

Examples:

```text
project export -o DEPT,EMP
project export -o GRAPH_MAIN
```

## APEX application export

Follow the governing workspace instructions for the supported APEX export command. When the workspace provides an alias such as `prj_exp_app`, use it instead of calling `project export -o APEX.<app_id>` directly.

If no workspace-specific alias exists and direct application export is supported:

1. Resolve the application and its exact source directory.
2. Delete only that application's existing export directory so removed components cannot linger.
3. Run the application export asynchronously through MCP and poll it to completion.

## Full export

A full `project export` re-exports everything selected by the project filters and may include APEX applications.

1. Preserve the current work according to the workspace policy. If the policy requires `git add .`, do that only when authorized and never create a commit unless requested.
2. Read `.dbtools/filters/project.filters`.
3. Collect uncommented predicates that constrain `APEX_APPLICATIONS` or `application_id`. Ignore line comments and block comments.
4. Query `apex_applications` through MCP using those predicates, removing table qualifiers such as `APEX_APPLICATIONS.` from the query columns.
5. Pre-delete only the application export directories returned by that query.
6. Run `project export` asynchronously through MCP and poll it to completion.

Do not broaden cleanup beyond the objects and applications in the resolved export scope.
