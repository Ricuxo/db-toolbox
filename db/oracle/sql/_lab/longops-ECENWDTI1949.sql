Rem
Rem    NOME
Rem      longops.sql 
Rem
Rem    DESCRI��O
Rem      Verificar varreduras integrais nas tabelas.
Rem
Rem    UTILIZA��O
Rem      @longops
Rem
Rem    ATUALIZA��ES  (MM/DD/YY)
Rem      FERR@RI      26/01/07 - cria��o do script
Rem
Rem ---------- ---------- ---------- ---------- ---------- ---------- ---------- ----------

@cab
column username  format a12         
column opname    format a20
column start     format a20
column elapsed   format a8
column remaining format a10
column machine   format a20


SELECT s.inst_id,
       s.sid,
       s.serial#,
       sl.username,
       sl.sql_hash_value, 
       sl.opname,
       TO_CHAR(sl.start_time,'dd/mm/yyyy HH24:MI:SS') AS "START",
       ROUND(sl.elapsed_seconds/60) || ':' || MOD(sl.elapsed_seconds,60) elapsed,
       ROUND(sl.time_remaining/60) || ':' || MOD(sl.time_remaining,60) remaining,
       ROUND(sl.sofar/sl.totalwork*100, 2) COMPLETE_PCT,
       s.machine
FROM   gv$session s,
       gv$session_longops sl
WHERE  s.sid     = sl.sid
AND    s.serial# = sl.serial#
AND    sl.totalwork <> 0
AND    ROUND(sl.sofar/sl.totalwork*100, 2) <> 100
ORDER BY S.SID;
/

PROMPT

