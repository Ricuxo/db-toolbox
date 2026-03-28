

ttitle 'High waits on events|Rollup by hour'


column mydate heading 'Yr.  Mo Dy Hr'     format a13;
column event                              format a30;
column total_waits    heading 'tot waits' format 999,999;
column time_waited    heading 'time wait' format 999,999;
column total_timeouts heading 'timeouts'  format 9,999;

break on to_char(snap_time,'yyyy-mm-dd') skip 1;
  select 
   to_char(e.sample_time,'yyyy-mm-dd HH24')   mydate,
   e.event,
   count(e.event)                               total_waits,
   sum(e.time_waited)                           time_waited
from 
   v$active_session_history e
where
   e.event not like '%timer' 
and 
   e.event not like '%message%'
and 
   e.event not like '%slave wait%'
having
   count(e.event) > 100
group by
   to_char(e.sample_time,'yyyy-mm-dd HH24'),
   e.event
order by 1     
;
