/*  */
column network format a10
column (sum(busy)/(sum(busy)+sum(idle)))*100 heading 'Busy Rate' format 999.99
column "Average Wait " format 9.99999999
select network, decode (sum(totalq),0,'No responses'),
sum(wait)/sum(totalq) ||' 100ths secs' "Average Wait "
from v$queue q, v$dispatcher d
where q.type='DISPATCHER' and q.paddr=d.paddr
group by network
/
select network, (sum(busy)/(sum(busy)+sum(idle)))*100
from v$dispatcher
group by network
/
