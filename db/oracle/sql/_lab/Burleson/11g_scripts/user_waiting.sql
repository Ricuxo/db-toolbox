/*  */
select 
   sess.sid,
   sess.username,
   sum(ash.wait_time + ash.time_waited) wait_time
from 
   v$active_session_history ash,
   v$session sess
where 
   ash.sample_time > sysdate-1
and 
   ash.session_id = sess.sid
group by 
   sess.sid, 
   sess.username
order by 3;
