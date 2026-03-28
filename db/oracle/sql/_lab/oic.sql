Rem
Rem    NOME
Rem      oic.sql  
Rem
Rem    DESCRIÇÃO
Rem      Este script lista informações sobre a utilização de espaço de um indice.
Rem      
Rem    UTILIZAÇÃO
Rem      @oic
Rem
Rem    ATUALIZAÇÕES  (MM/DD/YY)
Rem     FERR@RI       29/04/09 - criação do script
Rem
Rem ---------- ---------- ---------- ---------- ---------- ---------- ---------- ----------

PROMPT
PROMPT Lista informações sobre a utilização de espaço de um indice.
  
select MODULE,
       COUNT(*)
from gv$session
group by MODULE
order by 2
/

select INST_ID, 
       SID, 
       STATUS,
       MODULE 
from gv$session
where MODULE like 'cnPayrunsMain.jsp'
order by STATUS
/


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
       to_char(a.logon_time,'yyyy/mm/dd hh24:mi:ss') dtr,
       round((a.last_call_et/60),0) LAST_CALL_ET__MIN,
       a.program,
       a.prev_hash_value,
       a.module,
       a.machine,
       a.osuser,
       'alter system kill session '''||a.sid||','||a.serial#||''' immediate;' as Kill_session,
       'kill -9 '||b.spid||'' as Kill_UNIX
FROM   gv$session a, gv$process b
WHERE  a.paddr    = b.addr
AND    a.username = 'APPS'
AND    a.status = 'ACTIVE'
ORDER BY dtr ASC
/