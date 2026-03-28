/*  */
set linesize 100
 select
 sid,
 substr(event,1,25) "event",
 state,
 p1,
 p2,
 wait_time Wait,
 seconds_in_wait seconds
 from v$session_wait
 where event not like '%SQL*Net%' and
       event not in ('pmon timer', 'smon timer', 'rdbms ipc message')
/
