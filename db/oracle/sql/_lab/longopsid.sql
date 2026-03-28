Rem
Rem    NOME
Rem      longopsid.sql 
Rem
Rem    DESCRIÇÃO
Rem      Verificar varreduras integrais nas tabelas para um determinado SID.
Rem
Rem    UTILIZAÇÃO
Rem      @longopsid <sid>
Rem
Rem    ATUALIZAÇÕES  (MM/DD/YY)
Rem      FERR@RI      26/01/07 - criação do script
Rem
Rem ---------- ---------- ---------- ---------- ---------- ---------- ---------- ----------

@cab
column opname format a30
column elapsed format a10
column remaining format a10
column machine format a30


SELECT s.sid,
       s.serial#,
       sl.username,
       sl.sql_hash_value, 
       sl.opname,
       TO_CHAR(sl.start_time,'dd/mm/yyyy HH24:MI:SS') AS "START",
       ROUND(sl.elapsed_seconds/60) || ':' || MOD(sl.elapsed_seconds,60) elapsed,
       ROUND(sl.time_remaining/60) || ':' || MOD(sl.time_remaining,60) remaining,
       ROUND(sl.sofar/sl.totalwork*100, 2) PERCENT_COMPLETE,
       s.machine
FROM   v$session s,
       v$session_longops sl
WHERE  s.sid     = sl.sid
AND    s.serial# = sl.serial#
AND    s.sid = &1
/
