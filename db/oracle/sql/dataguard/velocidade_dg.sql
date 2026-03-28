PROMPT ### MRP0 waiting time (conectado no Physical Standby)
PROMPT ### views: gv$session_wait, gv$session, v$bgprocess
PROMPT ######################################################################

select a.event, a.wait_time, a.seconds_in_wait,  a.seconds_in_wait/60 as min_in_wait
from gv$session_wait a, gv$session b 
where a.sid=b.sid 
and b.sid=(select SID from v$session where PADDR=(select PADDR from v$bgprocess where NAME='MRP0'))
/


--EVENT                                           WAIT_TIME SECONDS_IN_WAIT
------------------------------------------------ ---------- ---------------
--parallel recovery control message reply                 0               0


PROMPT ### MRP0 speed (conectado no Physical Standby)
PROMPT ### views: v$recovery_progress
PROMPT ######################################################################
set linesize 400
col Values for a65
col Recover_start for a21
select 
to_char(START_TIME,'dd.mm.yyyy hh24:mi:ss') "Recover_start",to_char(item)
||' = '||to_char(sofar)||' '||to_char(units)||' '|| to_char(TIMESTAMP,'dd.mm.yyyy hh24:mi') "Values" 
from v$recovery_progress where start_time=(select max(start_time) from v$recovery_progress)
/
