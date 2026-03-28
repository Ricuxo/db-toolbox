/*  */
rem
rem tab_col.sql
rem
rem FUNCTION: Report on Table and View Column Definitions
rem
rem MRA 9/18/96
rem MRA 6/14/97 Added table level selectivity
rem
COLUMN owner 		FORMAT a10 	HEADING Owner
COLUMN table_name 	FORMAT a30 	HEADING "Table or View Name"
COLUMN COLUMN_name 	FORMAT a32 	HEADING "Table or View|Attribute"
COLUMN data_type 	FORMAT a15 	HEADING "Data|Type"
COLUMN data_type_owner  FORMAT a13      HEADING "Type|Owner"
COLUMN data_length 			HEADING Length
COLUMN nullable 	FORMAT a5 	HEADING Null
BREAK ON owner ON table_name SKIP 1
SET LINES 132 PAGES 48 FEEDBACK OFF VERIFY OFF
START title132 "Table Columns Report"
SPOOL rep_out/&db/tab_col
SELECT 
	a.owner,
	table_name||' '||object_type table_name, 
	column_name,
	data_type,
        data_type_owner,
	data_length,
	DECODE(nullable,'N','NO','YES') nullable
FROM 
	dba_tab_columns a, dba_objects b 
WHERE
	a.owner not in ('SYS','SYSTEM') AND
	a.owner=UPPER('&owner') AND
	a.owner=b.owner AND
	a.table_name LIKE UPPER('%&table%') AND
	a.table_name=b.object_name AND
	object_type IN ('TABLE','VIEW','CLUSTER')
ORDER BY 
	owner, 
	object_type,
	table_name, 
	column_id
/
SPOOL OFF
TTITLE OFF
SET LINES 80 PAGES 22 FEEDBACK ON VERIFY ON

