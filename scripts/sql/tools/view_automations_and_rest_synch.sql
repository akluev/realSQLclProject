--- To view automations 

select application_id, application_name, 
name automation_name, build_option,
polling_interval, 
polling_status
from APEX_APPL_AUTOMATIONS where working_copy_name is null
and trigger_type ='Schedule'
order by application_id 
/

-- To view RESTful Services Synchronizations

select application_id, application_name,
module_name, url_endpoint, 
sync_is_active, SYNC_INTERVAL
from APEX_APPL_WEB_SRC_MODULES
order by application_id , module_name
/

--To Enable a RESTful Services Synchronization

BEGIN
    apex_util.set_workspace(p_workspace => '&workspace_id.');
    apex_rest_source_sync.enable(
    p_application_id => 116,
    p_module_static_id => '&static_id.' );
END;
/

-- To Enable an Automation

BEGIN
    apex_automation.enable(
        p_application_id  => 116,
        p_static_id       => '&static_id.' );
END;
/

