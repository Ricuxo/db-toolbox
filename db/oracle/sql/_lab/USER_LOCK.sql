--Abaixo segue uma instrução que utilizo para pegar os valores de sessão dos usuários que executam JOBS e as vezes fica preso:

set line 200
set pagesize 10000
col what format a40
col username format a15
col machine format a15

select a.username, a.osuser, a.machine, a.sid, a.serial#, b.spid, c.job, c.what
from v$session a, v$process b, dba_jobs c, dba_jobs_running d
where a.paddr=b.addr and c.job=d.job and a.sid in (select sid from dba_jobs_running);