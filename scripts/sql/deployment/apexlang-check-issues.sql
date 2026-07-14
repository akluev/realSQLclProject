with refs as (
    select application_id, page_id, page_name,
           'Page Item' component_type,
           item_name component_name,
           'Item Type' plugin_type,
           display_as_code plugin_code
      from apex_application_page_items
    union all
    select application_id, page_id, page_name,
           'Page Region',
           region_name,
           case
             when source_type_plugin_name like 'TMPL\_%' escape '\'
             then 'Template Component'
             else 'Region Type'
           end,
           source_type_plugin_name
      from apex_application_page_regions
    union all
    select application_id, page_id, page_name,
           'Dynamic Action Action',
           dynamic_action_name || ' / ' || action_pd_name,
           'Dynamic Action',
           action_code
      from apex_application_page_da_acts
    union all
    select application_id, page_id, page_name,
           'Page Process',
           process_name,
           'Process Type',
           process_type_plugin_name
      from apex_application_page_proc
    union all
    select application_id, null, null,
           'Application Process',
           process_name,
           'Process Type',
           process_type_plugin_name
      from apex_application_processes
    union all
    select application_id, page_id, page_name,
           'Report Column',
           region_name || ' / ' || column_alias,
           'Report Column Type',
           display_as_code
      from apex_application_page_rpt_cols
    union all
    select application_id, page_id, page_name,
           'Page Validation',
           validation_name,
           'Validation Type',
           validation_type_code
      from apex_application_page_val
    union all
    select application_id, null, null,
           'Authentication Scheme',
           authentication_scheme_name,
           'Authentication Type',
           scheme_type_code
      from apex_application_auth
    union all
    select application_id, null, null,
           'Authorization Scheme',
           authorization_scheme_name,
           'Authorization Type',
           scheme_type_code
      from apex_application_authorization
    union all
    select application_id, null, null,
           'REST Data Source',
           module_name,
           'REST Data Source Type',
           web_source_type_code
      from apex_appl_web_src_modules
)
select r.application_id,
       r.page_id,
       r.page_name,
       r.component_type,
       r.component_name,
       r.plugin_type,
       r.plugin_code,
       case
         when r.plugin_code like 'TMPL\_%' escape '\' then substr(r.plugin_code, 6)
         else substr(r.plugin_code, 8)
       end missing_plugin_name
  from refs r
 where r.application_id = :APP_ID
   and (   r.plugin_code like 'PLUGIN\_%' escape '\'
        or r.plugin_code like 'TMPL\_%' escape '\' )
   and not exists (
           select 1
             from apex_appl_plugins p
            where p.application_id = r.application_id
              and p.plugin_type    = r.plugin_type
              and p.name           = case
                                       when r.plugin_code like 'TMPL\_%' escape '\'
                                       then substr(r.plugin_code, 6)
                                       else substr(r.plugin_code, 8)
                                     end )
 order by r.page_id nulls first,
          r.component_type,
          r.component_name;