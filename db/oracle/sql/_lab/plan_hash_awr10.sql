@save_sqlplus_settings

set lines 150
set pages 5000

set markup html preformat on
select plan_table_output from table(dbms_xplan.display_awr('&1',&2));

@restore_sqlplus_settings
