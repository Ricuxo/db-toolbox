Rem
Rem    NOME
Rem      ver.sql 
Rem
Rem    DESCRIÇÃO
Rem      Este script lista informações sobre as sessões ativas.
Rem
Rem    UTILIZAÇÃO
Rem      @ver
Rem
Rem    ATUALIZAÇÕES  (MM/DD/YY)
Rem      FERR@RI      27/12/06 - criação do script
Rem
Rem ---------- ---------- ---------- ---------- ---------- ---------- ---------- ----------

set pagesize 50
set linesize 1000
--set buffer 3000

col inst_id for 999
col logonTime for a20
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
col event for a30

UNDEFINE SID

SELECT a.inst_id,
       a.sid,
       a.serial#,
       b.pid as PID_ORACLE,
       b.spid as SPID_SO_SERVER,
       a.process as PROCESS_CLIENT,
       a.sql_address,
       a.sql_hash_value,
       a.username,
       a.status,
       to_char(a.logon_time,'yyyy/mm/dd hh24:mi:ss') logonTime,
       round((a.last_call_et/60),0) LAST_CALL_ET__MIN,
       a.program,
       c.event wait_event,
       a.module,
       a.machine,
       a.osuser,
       'alter system kill session '''||a.sid||','||a.serial#||''' immediate;' as Kill_session,
       'kill -9 '||b.spid||'' as Kill_UNIX
FROM   gv$session a, gv$process b, gv$session_wait c
WHERE  a.paddr    =  b.addr
AND    a.inst_id  =  b.inst_id
AND    a.sid	  =  c.sid
AND    a.inst_id  =  c.inst_id
AND    lower(a.username) like lower('&Username')
/

PROMPT