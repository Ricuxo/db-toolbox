/*  */
rem
rem Name: tab_part_stat.sql
rem Function : Report on partitioned table statistics
rem History: MRA 6/13/97 Created
rem
COLUMN table_name       FORMAT a13   HEADING 'Table'
COLUMN partition_name 	FORMAT a16   HEADING 'Partition'
COLUMN num_rows HEADING 'Num|Rows' format 9999999
COLUMN blocks HEADING 'Blocks' format 99999
COLUMN avg_space HEADING 'Avg|Space' format 99999
COLUMN chain_cnt HEADING 'Chain|Count' format 99999
COLUMN avg_row_len HEADING 'Avg|Row|Length' format 999999
COLUMN last_analyzed HEADING 'Analyzed'
ACCEPT owner1 PROMPT 'Which Owner to report on?:'
SET LINES 132
START title132 'Table Partition Statistics For &owner1'
BREAK ON table_owner ON table_name ON partition_name
SPOOL rep_out/&&db/tab_part_stat.lis
SELECT       
	table_name,             
	partition_name,
        num_rows,
        blocks,
        avg_space,
        chain_cnt,
        avg_row_len,
        pct_free,
        pct_used,
        ini_trans,
        freelists,
        to_char(last_analyzed,'dd-mon-yyyy hh24:mi') last_analyzed                      
FROM sys.dba_tab_partitions
WHERE table_owner LIKE UPPER('%&&owner1%')
ORDER BY table_owner,table_name
/
SPOOL OFF
CLEAR BREAKS
CLEAR COLUMNS
TTITLE OFF
UNDEF owner1
