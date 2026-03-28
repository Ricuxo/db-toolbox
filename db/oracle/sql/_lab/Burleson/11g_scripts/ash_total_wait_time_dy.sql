/*  */
--*************************************************
--    
--   Free for non-commercial use!  
--   To license, e-mail info@rampant.cc
-- ************************************************

select
   s.sid,
   s.username,
   sum(h.wait_time + h.time_waited) "total wait time"
from
   v$active_session_history     h,
   v$session                    s,
   v$event_name                 e
where
   h.session_id = s.sid
and
   e.event_id = h.event_id
and
   e.wait_class <> 'Idle'
and
   s.username IS NOT NULL
group by
   s.sid, s.username
order by 3
;
