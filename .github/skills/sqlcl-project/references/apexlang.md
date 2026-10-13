# APEXlang compile and validation

Use this workflow when the user asks to compile, import, or validate an APEX application from APEXlang source.

## Version requirement

Run the SQLcl version check through MCP. `apex import` and `apex validate` require SQLcl 26.1.2 or later (`_sqlplus_release >= 2601020000`). Stop and report an older or indeterminate version.

## Resolve application details

Never guess the workspace, owner, alias, or input path. After connecting and inspecting schema information, query through MCP:

```sql
select application_id,
       lower(owner)                                                                      as schema_lc,
       lower(alias)                                                                      as alias_lc,
       workspace,
       'src/database/' || lower(owner) || '/apex_apps/f' || application_id || '/' ||
       lower(alias)                                                                      as input_path
  from apex_applications
 where application_id = <app_id>;
```

If no row is returned, stop and report that the application was not found on the active connection.

## Validate

Validation is read-only and works through the MCP SQLcl-command tool:

```text
apex validate -input src/database/<schema>/apex_apps/f<app_id>/<alias> -ws <workspace>
```

## Import limitation

An MCP connection may use JDBC-level autocommit that `apex import` cannot disable, causing `ORA-17274`. SQLcl's script-level `set autocommit off` does not change that JDBC property.

If the active MCP implementation cannot run `apex import` safely, stop and report the MCP limitation. Do not invoke a local SQLcl executable or another database client as an agent workaround.

Projects may provide aliases such as `prj_compile` and `prj_validate` for humans using SQLcl directly. Their existence does not authorize the agent to bypass the required MCP workflow.

The bundled `sqlcl-project-aliases.xml` file can be loaded and persisted by a human SQLcl user when requested:

```text
alias load <path-to-skill>/sqlcl-project-aliases.xml
alias save
```
