/*  */
rem
rem NAME: tab_nest.sql
rem PURPOSE: Report on Nested Tables
rem HISTORY: MRA 6/14/97 Created
rem
COLUMN owner 			FORMAT a10 HEADING 'Owner'
COLUMN table_name 		FORMAT a15 HEADING 'Store Table'
COLUMN table_type_owner 	FORMAT a10 HEADING 'Type|Owner'
COLUMN table_type_name 	FORMAT a15 HEADING 'Type|Name'
COLUMN parent_table_name 	FORMAT a25 HEADING 'Parent|Table'
COLUMN parent_table_column 	FORMAT a12 HEADING 'Parent|Column'
COLUMN storage_spec             FORMAT a15  HEADING 'Storage|Spec'
COLUMN return_type              FORMAT a7  HEADING 'Return|Type'
SET PAGES 58 LINES 132 VERIFY OFF FEEDBACK OFF
START title132 'Nested Tables'
BREAK ON owner
SPOOL rep_out\&db\tab_nest.lis
SELECT
	owner,
	table_name,
	table_type_owner,   
	table_type_name,    
	parent_table_name,    
	parent_table_column,
        LTRIM(storage_spec) storage_spec,
        LTRIM(return_type) return_type
FROM sys.dba_nested_tables
ORDER BY owner;
SPOOL OFF
