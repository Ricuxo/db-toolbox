/*  */
set pages 54 lines 80
ttitle 'Tables and Indexes'
spool t_and_i
select tablespace_name,count(table_name) tables, null indexes
from dba_tables
group by tablespace_name
union
select tablespace_name,null tables, count(index_name) indexes
from dba_indexes
group by tablespace_name
/
spool off
ttitle off
