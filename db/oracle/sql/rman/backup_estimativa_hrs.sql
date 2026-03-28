col "% Complete" format 990D99
col "Done%" format 990D99
col sid format 99999
col qcsid format 99999
col Inicio format a8
col elapsed format 9999999
col remaining format 9999999
col message for a90

set lines 300

select sid, qcsid, sql_hash_value hash_value, message, to_char(start_time,'HH24:MI:SS') Inicio,
ELAPSED_SECONDS elapsed, TIME_REMAINING remaining, to_char(sysdate + (TIME_REMAINING/3600/24),'DD/MM/YYYY HH24:MI:SS')  Previsao
,round(sofar/totalwork*100,2) "Done%"
from v$session_longops l
where LAST_UPDATE_TIME >= sysdate -1
and totalwork <> 0
and time_remaining <> 0
order by start_time
/
