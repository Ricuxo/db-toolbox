SELECT s.inst_id,
       s.sid,
       s.serial#,
       sl.username,
       sl.opname,
       decode(ROUND(sl.sofar/sl.totalwork*100, 2),100,'FINISHED','NOT FINISHED'),
       ROUND(sl.sofar/sl.totalwork*100, 2) COMPLETE_PCT,
       TO_CHAR(sl.start_time,'dd/mm/yyyy HH24:MI:SS') AS "START",
       ROUND(sl.elapsed_seconds/60) || ':' || MOD(sl.elapsed_seconds,60) elapsed,
       ROUND(sl.elapsed_seconds/60/60) elapsed_HOURS,
       ROUND(sl.time_remaining/60) || ':' || MOD(sl.time_remaining,60) remaining,
       ROUND(sl.time_remaining/60/60) remaining_HOURS,
       sl.sql_hash_value,
       s.machine
       --SL.SQL_ID
FROM   gv$session s,
       gv$session_longops sl
WHERE  s.sid     = sl.sid
AND    s.serial# = sl.serial#
AND    sl.totalwork <> 0
AND    sl.username LIKE NVL(UPPER('&&1'),'%')
ORDER BY decode(ROUND(sl.sofar/sl.totalwork*100, 2),100,'FINISHED','NOT FINISHED')
/

