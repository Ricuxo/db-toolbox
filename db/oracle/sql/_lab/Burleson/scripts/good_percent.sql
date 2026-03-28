/*  */
column good_percent format 999.99 heading 'Percent Shared'
set feedback off 
@title80 'Shared Pool Utilization'
ttitle off
spool rep_out\&db\good_percent
select avg(b.good/(b.good+a.garbage))*100 good_percent
from sql_garbage a, sql_garbage b
where a.users=b.users
and a.garbage is not null and b.good is not null
/
spool off
