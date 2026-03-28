Rem
Rem    NOME
Rem      longopsuser.sql 
Rem
Rem    DESCRIÇÃO
Rem      Verificar varreduras integrais nas tabelas para um determinado USER.
Rem
Rem    UTILIZAÇÃO
Rem      @longopsuser <user>
Rem
Rem    ATUALIZAÇÕES  (MM/DD/YY)
Rem      FERR@RI      26/08/07 - criação do script
Rem
Rem ---------- ---------- ---------- ---------- ---------- ---------- ---------- ----------

column opname format a30
column elapsed format a10
column remaining format a10
column username format a15
column start format a20

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
AND    sl.time_remaining > 0
AND    sl.username = upper('&1')   
ORDER BY 8 desc
/

PROMPT
