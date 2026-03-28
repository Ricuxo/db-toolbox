/*  */
col sql_text format a40 word_wrapped heading 'SQL|Text'
col ave_parse_calls heading 'Ave|Parse|calls' 
col ave_disk_reads heading 'Ave|Disk|Reads' 
col ave_buffer_gets heading 'Ave|Buffer|Gets' 
col ave_row_proc heading 'Ave|Rows|proc' 
col ave_ser_aborts heading 'Ave|Ser|Aborts' 
col ave_cpu_time heading 'Ave|CPU|Time' 
col ave_elapsed_time heading 'Ave|Elapsed|Time' 
col per_mem heading 'Per|Mem'
col run_mem heading 'Run|Mem'
col ave_sorts heading 'Ave|Sorts'

set lines 160 pages 55
SELECT * FROM(
SELECT
sql_text, 
ceil(cpu_time/greatest(executions,1)) ave_cpu_time, 
ceil(elapsed_time/greatest(executions,1)) ave_elapsed_time,
ceil(disk_reads/greatest(executions,1)) ave_disk_reads,
persistent_mem per_mem, runtime_mem run_mem, 
ceil(sorts/greatest(executions,1)) ave_sorts, 
ceil(parse_calls/greatest(executions,1)) ave_parse_calls,
ceil(Buffer_gets/greatest(executions,1)) ave_buffer_gets, 
ceil(rows_processed/greatest(executions,1)) ave_row_proc,
ceil(Serializable_aborts/greatest(executions,1)) ave_ser_aborts
FROM
v$sqlarea
WHERE
Disk_reads/greatest(executions,1)>&&disk_reads
OR
Cpu_time/greatest(executions,1)>&&cpu_time
OR
Elapsed_time/greatest(executions,1)>&&elapsed_time
order by elapsed_time, cpu_time, disk_reads)
where rownum<11
/
