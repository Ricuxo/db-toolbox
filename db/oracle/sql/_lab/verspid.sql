Rem
Rem    NOME
Rem      verspid.sql 
Rem
Rem    DESCRIÇÃO
Rem      Este script mostra informações sobre um SPID especificado <SPID>
Rem
Rem    UTILIZAÇÃO
Rem      @verspid <spid>
Rem
Rem    ATUALIZAÇÕES  (MM/DD/YY)
Rem      FERR@RI      18/04/08 - criação do script
Rem
Rem ---------- ---------- ---------- ---------- ---------- ---------- ---------- ----------

set verify off

col inst_id for 999
col dtr for a20
col serial# for 99999
col username FOR A25
col status for A8 trunc
col osuser for A10
col machine for A35 trunc
col terminal for A15
col osuser for a20
col program for A35 trunc
col sid for 999999
col spid for 9999999
col process for a15
col kill_session for a50

SELECT a.sid,
       a.serial#,
       b.pid as PID_ORACLE,
       b.spid as SPID_SO_SERVER,
       a.process as PROCESS_CLIENT,
       a.sql_address,
       a.sql_hash_value,
       a.username,
       a.status,
       to_char(a.logon_time,'dd/mm/yyyy hh24:mi:ss') dtr,
       round((a.last_call_et/60),0) LAST_CALL_ET__MIN,
       a.program,
       a.prev_hash_value,
       a.module,
       a.machine,
       a.osuser,
       'alter system kill session '''||a.sid||','||a.serial#||''' immediate;' as Kill_session,
       'kill -9 '||b.spid||'' as Kill_UNIX
FROM   v$session a,
       v$process b
WHERE  a.paddr    = b.addr
AND    a.username IS NOT NULL
and    b.spid=&1
/

set verify on
undefine 1