REM - Mostra os nomes dos eventos do tipo latches


set pagesize 999
set linesize 1000

col inst_id for 999
col dtr for a20
col serial# for 99999
col username FOR A15
col status for A15
col osuser for A10
col machine for A35 
col terminal for A15
col osuser for a20
col program for A35 
col sid for 999999
col spid for 9999999
col process for a15
col kill_session for a50
col module for a35
col event for a15
col state for a20
	
UNDEFINE Event

SELECT 
       c.event,
       d.name latch_name,
       a.sid,
       a.serial#,
       a.username,
       a.status,
       a.sql_hash_value,
       c.state,
       c.seconds_in_wait,
       'alter system kill session '''||a.sid||','||a.serial#||''' immediate;' as "Kill Session"
FROM gv$session a, gv$process b, gv$session_wait c, v$latchname d
WHERE a.paddr    = b.addr
AND a.sid      = c.sid
AND c.p2	  = d.latch#   
AND c.event	  = 'latch free'
ORDER BY c.seconds_in_wait desc
/

