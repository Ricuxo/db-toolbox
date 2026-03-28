/*  */
col username format a10
col opname format a10
col target format a20
select opname,target,
to_char(start_time,'dd-mon-yy hh24:mi') start_time,
time_remaining,username
from v$session_longops where time_remaining>1 order by time_remaining
