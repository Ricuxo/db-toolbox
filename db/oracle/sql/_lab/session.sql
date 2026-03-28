set linesize 999
set pagesize 1000
col username for a10
col osuser for a10
col machine for a25

select s.username, s.sid, s.serial#, s.machine, s.status, s.osuser, s.program, 
p.spid 
from v$session s, v$process p 
where s.paddr = p.addr and s.osuser not in ('oracle') and s.status = 'ACTIVE';