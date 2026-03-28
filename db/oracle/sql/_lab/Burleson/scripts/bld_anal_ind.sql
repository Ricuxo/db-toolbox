/*  */
ttitle off
set pages 0
set feedback off verify off
spool rep_out\sieta\drop_anal_ind.sql
select	
	'analyze index '||index_name||
        ' delete statistics;'
from user_indexes;
spool off

