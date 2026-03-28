Rem
Rem    NOME
Rem      ver.sql 
Rem
Rem    DESCRIÇÃO
Rem      Lista as sessões de um determinado grupo de eventos de espera.
Rem
Rem    UTILIZAÇÃO
Rem      @ver_waits
Rem
Rem    ATUALIZAÇÕES  (MM/DD/YY)
Rem      LNoronha      09/12/09 - criação do script
Rem-------------------Short description to the possible values of the STATE column------------------------
Rem    WAITED UNKNOWN TIME: simply means that the TIMED_STATISTICS initialization parameter is 
Rem			    set to FALSE and Oracle is unable to determine the wait time. 
Rem			    In this case, the WAIT_TIME column shows –2.
Rem    WAITED SHORT TIME:   means the previous wait was less than one centisecond. 
Rem			    In this case, the WAIT_TIME column shows –1.
Rem    WAITING:             means that the session is currently waiting and the 
Rem			    WAIT_TIME column shows 0, but you can determine the time spent on this 
Rem			    current wait from the SECONDS_IN_WAIT column. 
Rem			    (Please note that SECONDS_IN_WAIT is in seconds, but WAIT_TIME is in 
Rem			    centiseconds.)
Rem    WAITED KNOWN TIME:   means Oracle is able to determine the duration of the last wait and the 
Rem			    time is posted in the WAIT_TIME column.



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
col event for a30
	
UNDEFINE Event

SELECT a.inst_id,
       a.sid,
       a.serial#,
       a.status,
       c.event,
       a.sql_hash_value,
--       a.sql_id,
       a.username,
       a.module,
       c.state,
       round((sysdate - a.logon_time) * 24) hours_connected,
       c.wait_time,
       c.seconds_in_wait,
       c.p1,
       c.p2,
       c.p3,
       c.p1text,
       c.p2text,
       c.p3text,
       a.module,
	'exec dbms_system.set_ev('''||a.sid||''','''||a.serial#||''',10046,12,'''');' as Trace_it,
	'alter system kill session '''||a.sid||','||a.serial#||''' immediate;' as Kill_session,
	'kill -9 '||b.spid||'' as Kill_UNIX
  FROM gv$session a, gv$process b, gv$session_wait c
 WHERE a.inst_id = b.inst_id
   AND a.inst_id = c.inst_id
   AND a.paddr    = b.addr
   AND a.sid      = c.sid
   AND c.event	  = '&&Event'
--   AND a.inst_id=2
ORDER BY a.sql_hash_value
/

