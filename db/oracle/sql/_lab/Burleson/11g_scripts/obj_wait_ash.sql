/*  */
select 
   obj.object_name,
   obj.object_type,
   ash.event,
   sum(ash.wait_time + ash.time_waited) wait_time
from 
   v$active_session_history ash,
   dba_objects              obj
where 
   ash.sample_time > sysdate -1 
and 
   ash.current_obj# = obj.object_id
group by 
   obj.object_name, 
   obj.object_type, 
   ash.event
order by 4 desc;
