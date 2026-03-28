/*  */
--*************************************************
--    
--   Free for non-commercial use!  
--   To license, e-mail info@rampant.cc
-- ************************************************

select
   o.owner,
   o.object_name,
   o.object_type,
   SUM(h.wait_time + h.time_waited) "total wait time"
from
   v$active_session_history     h,
   dba_objects                  o,
   v$event_name                 e  
where
   h.current_obj# = o.object_id
and
   e.event_id = h.event_id
and
   e.wait_class <> 'Idle'
group by
   o.owner, 
   o.object_name, 
   o.object_type
order by 4 DESC
;
