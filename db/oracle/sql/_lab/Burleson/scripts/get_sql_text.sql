/*  */
col sql_text format a40 word_wrapped heading 'SQL|Text'
col executions heading 'Executions'
col ave_cpu_time heading 'AVE|CPU|TIME'
col ave_elapsed_time heading 'AVE|ELAP|TIME'
col ave_disk_reads heading 'AVE|Disk|Reads'
col per_mem heading 'Per.|Mem'
col run_mem heading 'Run.|Mem'
col ave_sorts heading 'AVE|Sorts'
col ave_parse_calls heading 'AVE|Parse|Calls'
col ave_buffer_gets heading 'AVE|Buff|Gets'
col ave_row_proc heading 'AVE|Row|Proc.'
set lines 132 pages 1000
SELECT
sql_text, executions,
ceil(cpu_time/greatest(executions,1)) ave_cpu_time,
ceil(elapsed_time/greatest(executions,1)) ave_elapsed_time,
ceil(disk_reads/greatest(executions,1)) ave_disk_reads,
persistent_mem per_mem, runtime_mem run_mem,
ceil(sorts/greatest(executions,1)) ave_sorts,
ceil(parse_calls/greatest(executions,1)) ave_parse_calls,
ceil(Buffer_gets/greatest(executions,1)) ave_buffer_gets,
ceil(rows_processed/greatest(executions,1)) ave_row_proc
FROM
v$sqlarea
WHERE
Sql_text like '%&sub_str%'
/
