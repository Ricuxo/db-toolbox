/*  */
set lines 80 pages 55
column table_name format a25
@title80 'Actual to Analyzed Blocks'
spool rep_out\&&db\act_to_anal
select a.table_name, a.blocks actual_blocks, b.blocks anal_blocks, a.blocks/decode(b.blocks,0,1,b.blocks) ratio from
temp_size_table a, dba_tables b
where a.table_name=b.table_name
/
spool off
