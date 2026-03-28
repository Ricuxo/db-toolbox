REM " Script mostra Waits do tipo latches e seus nomes"
REM " Autor - Luiz Noronha - 27/04/2010"
REM 




set pagesize 50
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
col p1text for a20
col p2text for a20
col p3text for a20
col event for a15
col latch_name for A30
	
UNDEFINE Event

SELECT a.inst_id,
       a.sid,
       a.serial#,
       c.event,
       d.name latch_name,
       a.sql_hash_value,
       a.username,
       c.state,
       c.wait_time,
       c.seconds_in_wait,
       c.p1,
       c.p2,
       c.p3,
       c.p1text,
       c.p2text,
       c.p3text,
       a.module
  FROM gv$session a, gv$process b, gv$session_wait c, gv$latchname d
 WHERE a.paddr    = b.addr
   AND a.sid      = c.sid
   AND c.p2	  = d.latch#   
   AND c.event	  = 'latch free'
ORDER BY a.username
/

