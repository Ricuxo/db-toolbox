set lin 1000
col SNAP_INTERVAL for a30
col RETENTION for a30
SELECT * FROM dba_hist_wr_control;

prompt  Para alterar retencao:
prompt  exec dbms_workload_repository.modify_snapshot_settings(retention=>43200, interval=>60);   ---30 dias
prompt
prompt	The topnsql is used to specify the number of SQL to collect at each AWR snapshot for each criteria like elapsed time, CPU time, parse calls, shareable memory, and version count.  
prompt  The topnsql is normally set to a small number like 10, because you only want to see the most current SQL statements.  
prompt	This SQL information is normally purged after a period of time, after which the SQL source code is no longer needed. 
prompt  EX: exec dbms_workload_repository.modify_snapshot_settings(retention=>64800, interval=>60, topnsql=>10, dbid=>182126664);
prompt
