/*
1. Create a custom scrtipt to export ORDS module definition
*/

proj stage add-custom -file-name &modeule_id. -- replace by your module name

/*
2. Run the script below as schema owner CLA_APEX or CLA_PUBLIC (NOT as CLA_DEPLOYER!!!!) to export ORSS module definition
APPEND the output to the file created in step 1
*/

SELECT 
 REGEXP_REPLACE(
 ords_metadata.ords_export.export_module (
        p_module_name             => u.name,
        p_include_enable_schema   => false ,
        p_include_privs           => true ,
        p_privs_with_other_mod_refs   => true,
        p_export_date             => false
    ),
     'ORDS\.([^\(]*\()',
      'ORDS_ADMIN.\1
      p_schema => '''||user||''', ',
               1, 0, 'n'
    )||'
/
' stmt
  FROM USER_ORDS_MODULES u
  where u.name = '&modeule_id.' --- specify your module name here
/

