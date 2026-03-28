Rem
Rem    NOME
Rem      eventsession.sql 
Rem
Rem    DESCRIÇÃO
Rem      Este script lista as sessões que estão aguardando por um determinado evento de espera.
Rem
Rem    UTILIZAÇÃO
Rem      @eventsession
Rem
Rem    ATUALIZAÇÕES  (MM/DD/YY)
Rem      FERR@RI      27/12/06 - criação do script
Rem
Rem ---------- ---------- ---------- ---------- ---------- ---------- ---------- ----------
@cab
col event for a40

SELECT a.inst_id,
       a.sid,
       a.serial#,
       b.event, 
       b.seconds_in_wait,
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
FROM   gv$session a, gv$session_wait b
WHERE  a.sid = b.sid
AND    a.username  IS NOT NULL
AND    b.event = ('&1')
ORDER BY b.seconds_in_wait
/
