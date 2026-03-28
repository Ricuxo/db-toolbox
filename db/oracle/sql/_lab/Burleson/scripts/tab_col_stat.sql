/*  */
rem
rem tab_col_stat.sql
rem
rem FUNCTION: Report on Table and View Column Definitions
rem
rem MRA 9/18/96
rem MRA 6/14/97 Added table level selectivity
rem MRA 5/8/99 Converted to do stats
rem
COLUMN owner 		FORMAT a12 	HEADING Owner
COLUMN table_name 	FORMAT a20 	HEADING "Table Name"
COLUMN COLUMN_name 	FORMAT a13	HEADING "Table|Attribute"
COLUMN data_type 	FORMAT a10 	HEADING "Data|Type"
COLUMN avg_col_len      FORMAT 99,999   HEADING "Aver|Length"
COLUMN density          FORMAT 9.9999   HEADING "Density"
COLUMN last_analyzed                    Heading "Analyzed"
COLUMN num_distinct                     HEADING "Distinct|Values"
COLUMN num_nulls                        HEADING "Num.|Nulls"
COLUMN sample_size                      HEADING "Sample|Size"
BREAK ON owner ON table_name SKIP 1
SET LINES 132 PAGES 48 FEEDBACK OFF VERIFY OFF
START title132 "Table Column Stats Report"
SPOOL rep_out/&db/tab_col
select owner,table_name,column_name,data_type,
num_distinct,density,num_nulls,
to_char(last_analyzed,'dd-mon-yyyy hh24:mi') last_analyzed, 
sample_size, avg_col_len
from dba_tab_columns 
where owner like upper('%&owner%')
and table_name like upper('%&tabname%')
/
SPOOL OFF
TTITLE OFF
SET LINES 80 PAGES 22 FEEDBACK ON VERIFY ON

