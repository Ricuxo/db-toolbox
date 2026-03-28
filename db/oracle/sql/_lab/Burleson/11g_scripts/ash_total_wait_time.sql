/*  */
--*************************************************
--    
--   Free for non-commercial use!  
--   To license, e-mail info@rampant.cc
-- ************************************************

select
   h.event "Wait Event",
   SUM(h.wait_time/100) "Wait Time (Sec)"
from
   v$active_session_history     h,
   v$event_name                 n
where
   h.session_state = 'ON CPU'
and
   h.session_type = 'FOREGROUND'
and
   h.event_id = n.EVENT_ID
and
   to_char(h.sample_time,'HH24') = '12'
and
   n.wait_class <> 'Idle'
group by
   h.event
order by
  2 DESC
;
