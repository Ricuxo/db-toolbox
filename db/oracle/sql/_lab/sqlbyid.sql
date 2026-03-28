set long 999999
set linesize 999

select sql_fulltext
from v$sql
where sql_id = '&SQLID'
/

set linesize 300
