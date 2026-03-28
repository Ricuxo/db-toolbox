/*  */
set lines 130 pages 3000 heading on feedback off
COLUMN TABLE_NAME FORMAT A26 HEADING 'Table Name'
column column_name format a22 heading 'Column Name'
column comments format a30 heading 'Description' word_wrapped
column data_type format a9 heading 'Data Type'
break on table_name skip 1
spool desc_non_dba_views.doc
select a.table_name,a.column_name,a.data_type,
decode(a.nullable,'N','not null','') "Null?", b.comments
from dba_tab_columns a, dba_col_comments b, dba_objects c
where 
A.OWNER='SYS' AND
c.owner=a.owner and
a.table_name=c.object_name and
c.object_type='VIEW' and
(a.table_name NOT like 'DBA_%' AND
A.TABLE_NAME NOT LIKE 'ALL_%' AND
A.TABLE_NAME NOT LIKE 'USER_%' AND
A.TABLE_NAME NOT LIKE 'GV%' AND
A.TABLE_NAME NOT LIKE 'V$%' AND
A.TABLE_NAME NOT LIKE 'V_$%' AND
A.TABLE_NAME NOT LIKE '%$' and
a.table_name not like 'AQ%' and
a.table_name not like 'EXU%' and
a.table_name not like 'DEF%' and
a.table_name not like 'HS%' and
a.table_name not like 'IMP%' and
a.table_name not like 'ORA%' and
a.table_name not like 'LOADER%' and
a.table_name not like 'SM%' and
a.table_name not like 'SYS%' and
a.table_name not like 'TS%') AND
a.table_name=b.table_name and
a.column_name=b.column_name(+)
order by a.table_name,a.column_id
/
spool off
