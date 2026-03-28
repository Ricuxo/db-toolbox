/*  */
rem
rem Name: tab_subpart.sql
rem Function : Report on partitioned table structure
rem History: MRA 6/13/97 Created
rem
COLUMN table_owner NEW_VALUE owner1 NOPRINT
COLUMN table_name       FORMAT a15 HEADING 'Table'
COLUMN partition_name 	FORMAT a15 HEADING 'Partition'
COLUMN tablespace_name 	FORMAT a15 HEADING 'Tablespace'
COLUMN initial_extent   FORMAT 9,999 HEADING 'Initial|Extent (K)'
COLUMN next_extent      FORMAT 9,999 HEADING 'Next|Extent (K)'
COLUMN pct_increase     FORMAT 999 HEADING 'PCT|Increase'
COLUMN subpartition_name FORMAT a15 HEADING 'Sub|Partition'
SET LINES 130 head on
START title132 'Table Sub-Partition Files For &owner1'
BREAK ON table_owner ON table_name ON partition_name
SPOOL rep_out/&&db/tab_subpart.lis
SELECT
	table_owner,            
	table_name,             
	partition_name,
        subpartition_name,                      
	tablespace_name,        
	logging,
        initial_extent/1024 initial_extent,
        next_extent/1024 next_extent,
        pct_increase                 
FROM sys.dba_tab_subpartitions
ORDER BY table_owner,table_name,partition_name
/
SPOOL OFF
