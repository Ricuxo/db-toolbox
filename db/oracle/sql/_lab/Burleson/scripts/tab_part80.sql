/*  */
rem
rem Name: tab_part.sql
rem Function : Report on partitioned table structure
rem History: MRA 6/13/97 Created
rem
COLUMN table_owner     FORMAT a10 HEADING 'Owner'
COLUMN table_name      FORMAT a28 HEADING 'Table'
COLUMN partition_name  FORMAT a15 HEADING 'Partition'
COLUMN tablespace_name FORMAT a15 HEADING 'Tablespace'
COLUMN high_value      FORMAT a50 HEADING 'Partition|Value'
COLUMN subpartition_count FORMAT 9,999 HEADING 'Sub-Partitions'
SET LINES 130
START title132 'Table Partition Files'
BREAK ON table_owner ON table_name
SPOOL rep_out/&&db/tab_part.lis
SELECT
     table_owner,
     table_name,
     partition_name,
     high_value,
     tablespace_name,
     logging
FROM sys.dba_tab_partitions
ORDER BY table_owner,table_name
/
SPOOL OFF

