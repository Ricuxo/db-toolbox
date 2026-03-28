/*  */
select 
   ash.event,
   sum(ash.wait_time +
   ash.time_waited) ttl_wait_time
from 
   v$active_session_history ash
where 
   ash.sample_time between sysdate - 60/2880 and sysdate
group by 
   ash.event
order by 2;
