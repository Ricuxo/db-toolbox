REM monit_import
REM Script para monitorar progresso do import

col table_name for a40
set lin 1000
select substr(sql_text,instr(sql_text,'INTO "'),40) table_name,
         rows_processed,
         round((sysdate-to_date(first_load_time,'yyyy-mm-dd hh24:mi:ss'))*24*60,1) minutes,
         trunc(rows_processed/((sysdate-to_date(first_load_time,'yyyy-mm-dd hh24:mi:ss'))*24*60)) rows_per_min
  from   sys.v_$sqlarea
  where  sql_text like 'INSERT%INTO%'
    and  command_type = 2
    and  open_versions > 0;
