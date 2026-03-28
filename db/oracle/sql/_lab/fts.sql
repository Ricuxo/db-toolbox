prompt 'Localizando Full Table Scan - evento: db file scattered read...';

select count(*),
B.EVENT, d.spid OSPID, A.SID, A.SERIAL#, A.USERNAME, A.STATUS, A.MACHINE, A.PROGRAM, A.MODULE, substr(c.SQL_TEXT,1,40) sql_text, c.address, b.p1,b.p2,b.p3, (a.last_call_et / 60) last_call_et_minutos
from gv$session A, gV$SESSION_WAIT B, gv$sql c, gv$process d
where
A.SID=B.sid AND
b.EVENT = 'db file scattered read' and
a.SQL_ADDRESS=c.address and
a.paddr = d.addr
group by B.EVENT, d.spid , A.SID, A.SERIAL#, A.USERNAME, A.STATUS, A.MACHINE, A.PROGRAM, A.MODULE, substr(c.SQL_TEXT,1,40), c.address, b.p1,b.p2,b.p3, (a.last_call_et / 60)
order by username, machine;
