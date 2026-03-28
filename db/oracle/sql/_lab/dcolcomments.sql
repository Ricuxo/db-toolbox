set linesize 5000
set pagesize 9999

col "TABLE" format a61
col COLUMN_NAME format a30
col COMMENTS format a4000

select OWNER||'.'||TABLE_NAME "TABLE"
     , COLUMN_NAME
     , COMMENTS
  from DBA_COL_COMMENTS
 where owner like NVL('&LOWNER', OWNER)
   and table_name like NVL('&LTABLE_NAME', TABLE_NAME)
   and column_name like NVL('&LCOLNAME', COLUMN_NAME)
/

set linesize 165