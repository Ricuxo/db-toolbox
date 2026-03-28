set pagesize 999
set linesize 160

select decode(column_id, 1, 'SELECT ', '     , ')||column_name RESULTS
     , COLUMN_ID
     , COLUMN_NAME 
  from dba_tab_columns
 where OWNER = upper('&OWNER')
   and TABLE_NAME = upper('&TABLE_NAME')
 order by column_id
/
