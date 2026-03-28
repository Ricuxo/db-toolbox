/*  */
col "buf/row" format A12
col "buffer" format A14
col "disk/row" format A12
col "disk" format a14
col "%disk" format a5
col "rows" format a10
col executions format 999,990 head "Executes"
col sql_text format a30 word_wrapped
set lines 132 pages 55
start title132 'SQL Statistics'
spool rep_out\&db\sql_stat
select
to_char(round(buffer_gets/(decode(rows_processed,0,1,
rows_processed))),'999,999,990') "buf/row",
  to_char(buffer_gets,'9,999,999,990') "buffer",
to_char(round(disk_reads/(decode(rows_processed,0,1,
rows_processed))),'999,999,990') "disk/row",
  to_char(disk_reads,'9,999,999,990') "disk",
  to_char(round(disk_reads/(disk_reads+buffer_gets+1)*100))||' %' 
"%disk",
  to_char(rows_processed,'9,999,990') "rows",
  executions,
  first_load_time "1st time",
  sql_text
from
  v$sqlarea
where disk_reads >&disk_reads
order by 3 desc -- by 1 desc;
spool off
ttitle off
set lines 80
