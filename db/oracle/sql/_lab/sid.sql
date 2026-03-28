select 
a.sid, a.serial#,c.spid,a.inst_id,a.username,  a.machine, a.osuser, to_char(a.logon_time,'dd-mon-rr hh24:mi:ss') logon_time, a.status,b.address,b.sql_text, a.last_call_et
from gv$session a, gv$sql b, gv$process c
where 
a.SQL_ADDRESS=b.ADDRESS(+) and
a.inst_id=b.inst_id(+) and
a.paddr=c.addr and
a.inst_id=c.inst_id and
a.sid=&sid
order by 1,2;

prompt "Estatisticas da sessão:"
SELECT A.SID, B.NAME, A.VALUE FROM V$SESSTAT A, V$STATNAME B 
WHERE A.SID=&sid AND A.VALUE >0 AND
A.STATISTIC#=B.STATISTIC#
ORDER BY A.VALUE DESC;

select * from v$session_wait where sid=&sid;