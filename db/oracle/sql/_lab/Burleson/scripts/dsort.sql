/*  */
column username format a10
column name format a15 heading Parameter
@title80 'Disk Sorts by User'
spool rep_out\&db\dsort_user
select c.username,b.name,a.sid,a.value 
from v$sesstat a, v$statname b, v$session c
where a.statistic#=b.statistic# and
b.name like '%disk%' and
a.sid=c.sid and
a.value>0
/
spool off
clear col
ttitle off

