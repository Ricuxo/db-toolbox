/*  */
--*************************************************
--    
--   Free for non-commercial use!  
--   To license, e-mail info@rampant.cc
-- ************************************************

select
   TO_CHAR(h.sample_time,'HH24') "Hour",
   Sum(h.wait_time/100) "Total Wait Time (Sec)"
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
   n.wait_class <> 'Idle'
group by
   TO_CHAR(h.sample_time,'HH24');
