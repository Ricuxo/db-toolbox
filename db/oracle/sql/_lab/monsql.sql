select to_char(DATA,'DD/MM-HH24:MI'),HASH_VALUE,EXECUTIONS from sysdba.monitor_sql where hash_value='3502367437' order by hash_value,data
/
