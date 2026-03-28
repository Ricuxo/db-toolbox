prompt # 
prompt # Lock realizado em OBJETO (LOCK de dicionario)
prompt # 
select distinct 'kill -9 '||p.spid, '#', v.sid, v.username, v.osuser, v.module, v.program, v.lockwait
from DBA_DDL_LOCKS DDL, V$SESSION V, V$PROCESS P
WHERE DDL.SESSION_ID =V.SID
AND   V.PADDR=P.ADDR
and   v.username is not null
AND   DDL.NAME like upper('&object_name');
