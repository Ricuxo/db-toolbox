Rem
Rem    NOME
Rem      versid.sql 
Rem
Rem    DESCRIÇÃO
Rem      Este script lista informações sobre uma sessão especifica.
Rem
Rem    UTILIZAÇÃO
Rem      @versid <sid>
Rem
Rem    ATUALIZAÇÕES  (MM/DD/YY)
Rem      FERR@RI      18/04/08 - criação do script
Rem
Rem ---------- ---------- ---------- ---------- ---------- ---------- ---------- ----------
set verify off
set pagesize 50
set linesize 3000
set buffer 3000

col inst_id for 999
col dtr for a20
col serial# for 99999
col username FOR A25
col status for A3 trunc
col osuser for A10
col machine for A35 trunc
col terminal for A15
col osuser for a20
col program for A25 trunc
col sid for 999999
col spid for 9999999
col process for a15

SELECT 
       a.INST_ID,a.sid,
       a.serial#,
       b.pid as PID_ORACLE,
       b.spid as SPID_SO_SERVER,
       a.process as PROCESS_CLIENT,
       a.SQL_CHILD_NUMBER,
       a.sql_address,
       a.sql_id,
       a.sql_hash_value,
       a.wait_class,
       a.username,
       a.status,
       to_char(a.logon_time,'dd/mm/yyyy hh24:mi:ss') dtr,
       round((a.last_call_et/60),0) LAST_CALL_ET__MIN,
       a.program,
       a.prev_hash_value,
       a.module,
       a.machine,
       a.osuser,
       'alter system kill session '''||a.sid||','||a.serial#||''' immediate;' as "Kill Session"
FROM   gv$session a, gv$process b
WHERE  a.paddr    = b.addr
AND    a.username  IS NOT NULL
AND    a.sid in ('&1')
ORDER BY dtr ASC
/

set verify on