@save_sqlplus_settings

prompt
prompt Usage: @plan_hash_10g <sql_id> <child_number>

set lines 150
set pages 5000

set markup html preformat on
select plan_table_output from table(dbms_xplan.display_cursor('&1',&2,'ALLSTATS'));

@restore_sqlplus_settings
