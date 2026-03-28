/*  */
rem block_usage.sql
rem FUCTION: show block usage inside SGA
rem MRA
rem
break on report
compute sum of distinct_blocks on report
compute sum of blocks on report
@title80 'Block Usage Inside SGA Block Buffers'
spool rep_out\&db\block_usage
SELECT decode(b.tablespace_name,null,'UNUSED',b.tablespace_name) ts_name,
       a.file# file_number,
       COUNT(a.block#) Blocks,
       COUNT (DISTINCT a.file# || a.block#) Distinct_blocks
   FROM V$BH a, dba_data_files b
   WHERE a.file#=b.file_id(+)
   GROUP BY a.file#,decode(b.tablespace_name,null,'UNUSED',b.tablespace_name)
/
spool off
ttitle off


