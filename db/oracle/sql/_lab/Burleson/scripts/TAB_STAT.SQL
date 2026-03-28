/*  */
rem
rem  NAME: tab_stat.sql
rem
rem  FUNCTION:  Will show table statistics for a user's tables or all tables.
rem
 set pages 56 lines 140 newpage 0 verify off echo off feedback off
rem
column owner            format a7            heading "Table|Owner"
column table_name       format a30            heading "Table"
column tablespace_name  format a13            heading "Tablespace"
column num_rows         format 999,999    heading "Rows"
column blocks           format 99,999        heading "Blocks" 
column empty_blocks     format 99,999        heading "Empties" 
column space_full       format 9999.99         heading "% Full" 
column chain_cnt        format 9,999        heading "Chains"
column avg_row_len      format 99,999 heading "Avg|Length|(Bytes)"
column num_freelist_blocks format 99,999     heading "Num|Freelist|Blocks"
column avg_space_freelist_blocks FORMAT 9,999 heading "Avg Space|Freelist|Blocks"
rem
start title132 "Table Statistics Report"
DEFINE OUTPUT = 'rep_out\&db\tab_stat..lis'
spool &output
rem
BREAK ON OWNER SKIP 2 ON TABLESPACE_NAME SKIP 1;
select owner, table_name, tablespace_name, num_rows, blocks,
	empty_blocks,  
	100*((NUM_ROWS * AVG_ROW_LEN)/((GREATEST(blocks,1) + empty_blocks) * 2048)) space_full,
	chain_cnt, avg_row_len,avg_space_freelist_blocks, num_freelist_blocks
from dba_tables
WHERE OWNER NOT IN ('SYS','SYSTEM') and num_rows is not null
union
select owner, table_name, tablespace_name, num_rows, blocks,
	empty_blocks,  
	100*((NUM_ROWS * AVG_ROW_LEN)/((GREATEST(blocks,1) + empty_blocks) * 2048)) space_full,
	chain_cnt, avg_row_len,avg_space_freelist_blocks, num_freelist_blocks
from dba_object_tables
WHERE OWNER NOT IN ('SYS','SYSTEM') and num_rows is not null
order by owner, tablespace_name;
spool off
pause Press enter to continue
 set pages 22 lines 80 newpage 1 verify on feedback on
clear columns
clear breaks
ttitle off

