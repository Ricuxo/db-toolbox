/*  */
column protocol format a8
set embedded off
@title80 'Network Statistics'
spool rep_out/&db/network
select statistic,to_char(value) value from sys.v_$pq_sysstat;
select network "Protocol",to_char((sum(busy)/(sum(busy)+sum(idle))*100),'99.99999') "%Busy"
from v$dispatcher
group by network;
select network "Protocol",
decode(sum(totalq), 0, 'No Responses',
to_char(sum(wait)/sum(totalq),'99.99999')||' hundreths of seconds') "AWT/Response"
from v$queue q, v$dispatcher d
where q.type='DISPATCHER'
and q.paddr=d.paddr
group by network
/
spool off
