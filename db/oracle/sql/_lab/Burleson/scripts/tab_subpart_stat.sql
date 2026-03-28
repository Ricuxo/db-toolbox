/*  */
rem
rem Name: tab_subpart_stat.sql
rem Function : Report on partitioned table structure
rem History: MRA 6/13/97 Created
rem
COLUMN table_name       FORMAT a15   HEADING 'Table'
COLUMN partition_name 	FORMAT a15   HEADING 'Partition'
COLUMN subpartition_name FORMAT a15  HEADING 'Sub|Partition'
COLUMN num_rows HEADING 'Num|Rows'
COLUMN blocks HEADING 'Blocks'
COLUMN avg_space HEADING 'Avg|Space'
COLUMN chain_cnt HEADING 'Chain|Count'
COLUMN avg_row_len HEADING 'Avg|Row|Length'
COLUMN last_analyzed HEADING 'Analyzed'
ACCEPT owner1 PROMPT 'Which Owner to report on?:'
SET LINES 130
START title132 'Table Sub-Partition Statistics For &owner1'
BREAK ON table_owner ON table_name ON partition_name
SPOOL rep_out/&&db/tab_subpart_stat.lis
SELECT       
	table_name,             
	partition_name,
        subpartition_name,
        num_rows,
        blocks,
        avg_space,
        chain_cnt,
        avg_row_len,
        to_char(last_analyzed,'dd-mon-yyyy hh24:mi') last_analyzed                      
FROM sys.dba_tab_subpartitions
WHERE table_owner LIKE UPPER('%&&owner1%')
ORDER BY table_owner,table_name,partition_name
/
SPOOL OFF
CLEAR BREAKS
CLEAR COLUMNS
TTITLE OFF
UNDEF owner1
