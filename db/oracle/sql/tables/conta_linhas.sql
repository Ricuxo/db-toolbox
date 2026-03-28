col owner for a30
col table_name for a30
set lines 500
set pages 10000
select owner, table_name, nvl(num_rows,-1) rowcount
from dba_tables 
order by nvl(num_rows,-1) desc;