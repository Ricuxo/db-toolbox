set linesize 300
set pagesize 9999

column SID format 9999999999
column SERIAL# format 9999999999
column USERNAME format a15
column STATUS format a8
column MACHINE format a64
column "Description" format a80
column sid_blocker format 9999999999
column blocking_instance format 9999999999
column mysqlid format a13

select SID
     , SERIAL#
     , USERNAME
     , STATUS
     , decode(state, 'WAITING','Waiting','Working') state
     , decode(state, 'WAITING','So far '||seconds_in_wait, 'Last waited '||wait_time/100) ||' secs for '|| event "Description"
     , MACHINE
     , sql_id mysqlid
     , blocking_session sid_blocker
     , blocking_instance instance_blocker
from v$session
where USERNAME like NVL('&LUSERNAME', USERNAME)
  and STATUS = NVL('&STATUS',STATUS)
  and SID = NVL('&SID', SID)
/

prompt consider to run whatsblocked
prompt or run vsess_wait
prompt and sqlbyid
prompt

@reset