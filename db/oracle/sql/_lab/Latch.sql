Prompt 'Localizando Latch Free ...';
select distinct a.inst_id,
B.EVENT, d.name "Tipo do Latch", A.SID, A.SERIAL#, A.USERNAME, A.STATUS, A.MACHINE, A.PROGRAM, A.MODULE, 
B.P1, B.P2, c.SQL_TEXT, c.address,
round(a.last_call_et/(60),0) Minutos
from gv$session A, gV$SESSION_WAIT B, gv$sql c, gV$LATCH D
where
A.SID=B.sid AND
b.EVENT = 'latch free' and
a.SQL_ADDRESS=c.address(+) AND
b.p2=d.LATCH#
order by username, machine;