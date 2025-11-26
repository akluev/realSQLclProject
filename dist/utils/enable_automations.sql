--- This srcipt is a workardound to enable automations and REST Datasource Sync in APEX after installation
--- as they are disabled by default.

set serveroutput on

prompt Enable Automations 

begin
 for rec in (
    select 
    a.workspace,
    application_id, application_name, 
    name automation_name, build_option,
    a.static_id,
    polling_interval, 
    polling_status
    from APEX_APPL_AUTOMATIONS a  
    where working_copy_name is null
    and TRIGGER_TYPE_CODE ='POLLING'
    and POLLING_STATUS_CODE ='DISABLED'
    and build_option = 'Enable on Promotion' -- add entries here for each Automation to enable based on build option
    order by a.workspace, a.application_id, a.static_id 
 )  loop
    apex_util.set_workspace(p_workspace => rec.workspace);
    apex_automation.enable(
        p_application_id  => rec.application_id,
        p_static_id       => rec.static_id );
    dbms_output.put_line('Enabled Automation: ' || rec.application_name || ' - ' || rec.automation_name);
 end loop;
 end;
/

commit
/

prompt Enable RESTful Services Synchronizations


begin
 for rec in (
    select 
    a.workspace,
    application_id, application_name,
    module_name, url_endpoint, 
    sync_is_active, SYNC_INTERVAL,
    a.module_static_id
    from APEX_APPL_WEB_SRC_MODULES a
    where sync_is_active = 'No'
    and a.application_id||'#'||a.module_static_id in 
    (
    'APP_ID#MODULE_STATIC_ID'  -- add entries here for each REST module to enable
    )
    order by a.workspace, a.application_id , a.module_static_id
 )  loop
    apex_util.set_workspace(p_workspace => rec.workspace);
    apex_rest_source_sync.enable(
        p_application_id => rec.application_id,
        p_module_static_id => rec.module_static_id );
    dbms_output.put_line('Enabled RESTful Services Synchronization: ' || rec.application_name || ' - ' || rec.module_name);
 end loop;
 end;
 /

 commit
/
