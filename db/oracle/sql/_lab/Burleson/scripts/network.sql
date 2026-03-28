/*  */
select statistic,to_char(value) from sys.v$pq_sysstat
union
select network "Statistic",to_char(sum(busy)/(sum(busy)+sum(idle))) "Value"
from v$dispatcher
union
select network "Statitistic",
decode(sum(totalq), 0, 'No Responses',
sum(wait)/sum(totalq)||' hundreths of seconds')
from v$queue q, v$dispatcher d
where q.type='DISPATCHER'
and q.paddr=d.paddr
group by network "Statistic"; 
