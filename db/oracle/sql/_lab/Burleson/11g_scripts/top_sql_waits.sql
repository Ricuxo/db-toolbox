/*  */
select 
   ash.user_id,
   u.username,
   sqla.sql_text,
   sum(ash.wait_time + ash.time_waited) wait_time
from 
   v$active_session_history ash,
   v$sqlarea                sqla,
   dba_users                u 
where 
   ash.sample_time > sysdate-1
and 
   ash.sql_id = sqla.sql_id
and 
   ash.user_id = u.user_id
group by 
   ash.user_id,
   sqla.sql_text, 
   u.username
order by 4;
