Rem
Rem    NOME
Rem      verwaituser.sql  
Rem
Rem    DESCRIÇÃO
Rem      Este script verifica quais eventos de espera as sessões de um usuario está aguardando
Rem      
Rem    UTILIZAÇÃO
Rem      @verwaituser <username>
Rem
Rem    ATUALIZAÇÕES  (MM/DD/YY)
Rem      FERR@RI      17/07/08 - criação do script
Rem
Rem ---------- ---------- ---------- ---------- ---------- ---------- ---------- ----------

set pages 100
set verify off

col username for a10

select s.USERNAME,
       sw.SID, 
       sw.EVENT, 
       sw.P1TEXT, 
       sw.P1, 
       sw.P2TEXT, 
       sw.P2, 
       sw.P3TEXT, 
       sw.P3, 
       sw.SECONDS_IN_WAIT
from gv$session_wait sw, gv$session s 
where sw.SID = s.SID
  and sw.SID in (select sid from v$session where username = upper('&1'))
order by 10
/

set verify on