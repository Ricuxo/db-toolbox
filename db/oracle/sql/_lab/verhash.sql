Rem
Rem    NOME
Rem      verhash.sql 
Rem
Rem    DESCRIÇÃO
Rem      Este script lista informações sobre as sessões ativas para um determinado hash_value
Rem
Rem    UTILIZAÇÃO
Rem      @verhash <sql_hash_value>
Rem
Rem    ATUALIZAÇÕES  (MM/DD/YY)
Rem      FERR@RI      07/08/08 - criação do script
Rem
Rem ---------- ---------- ---------- ---------- ---------- ---------- ---------- ----------

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

SELECT a.inst_id,
       a.sid,
       a.serial#,
       b.spid,
       a.process,
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
       'alter system kill session '''||a.sid||','||a.serial#||''' immediate;' as "Kill Session"
FROM   gv$session a, gv$process b
WHERE  a.paddr    = b.addr
AND    a.username  IS NOT NULL
AND    a.status = 'ACTIVE'
AND    a.sql_hash_value = ('&1')
ORDER BY inst_id, dtr ASC
/
