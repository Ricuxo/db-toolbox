col event for a20
col name for a30
set pages 1000
break on P2 skip 1 nodup on NAME nodup on EVENT nodup

select s.p2, l.name, s.event, se.sql_hash_value, count(1) qtde
from gv$session_wait s, gv$latch l, gv$session se
where s.event = 'latch free'
and   s.p2 = l.latch#
and   s.sid = se.sid
group by s.p2,l.name,s.event, se.sql_hash_value
order by s.p2, l.name, s.event, qtde
/
select s.p2,l.name,s.event,count(1) qtde
from gv$session_wait s, gv$latch l
where s.event = 'latch free'
and   s.p2 = l.latch#
group by s.p2,l.name,s.event
/
@t3
clear breaks
