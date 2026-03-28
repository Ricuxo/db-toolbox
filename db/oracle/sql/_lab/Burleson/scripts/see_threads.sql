/*  */
rem see_threads.sql
rem example select to see threads on NT with names
rem Mike Ault
col Process format a7 heading 'Process'
col username format a10 heading 'Owner'
col thread format 999999 heading 'Decimal|Thread'
col non_con heading 'Hex|Thread'
col pid heading 'PID'
set trimspool on
@title80 "Oracle Threads Report"
spool rep_out\&db\see_threads
select 
	decode(b.name,null,'User',b.name) Process, 
	decode(s.username,null,'Internal',s.username) username, 
	dba_utilities.hextointeger(p.spid) Thread,p.spid non_con,p.pid
from 
	v$bgprocess b, 
	v$session s, 
	v$process p
where 
	p.addr=b.paddr(+)
	and p.addr=s.paddr(+)
order by 5
/
spool off
