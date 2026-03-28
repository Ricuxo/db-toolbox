 	Rem
Rem    NOME
Rem      verwait.sql  
Rem
Rem    DESCRIÇÃO
Rem      Este script mostra o recurso ou evento pelo qual a sessão está aguardando.      
Rem
Rem    UTILIZAÇÃO
Rem      @verwait <SID> 
Rem
Rem    ATUALIZAÇÕES  (MM/DD/YY)
Rem      FERR@RI      06/03/08 - criação do script
Rem
Rem ---------- ---------- ---------- ---------- ---------- ---------- ---------- ----------

col EVENT for a30
col P1TEXT for a15
col P2TEXT for a15
col P3TEXT for a15
set FEEDBACK off

select SID, EVENT, P1TEXT, P1, P2TEXT, P2, P3TEXT, P3, SECONDS_IN_WAIT
from v$session_wait
where SID = ('&1')
/
select SID, EVENT, P1TEXT, P1, P2TEXT, P2, P3TEXT, P3, SECONDS_IN_WAIT
from v$session_wait
where SID = ('&1')
/
select SID, EVENT, P1TEXT, P1, P2TEXT, P2, P3TEXT, P3, SECONDS_IN_WAIT
from v$session_wait
where SID = ('&1')
/
select SID, EVENT, P1TEXT, P1, P2TEXT, P2, P3TEXT, P3, SECONDS_IN_WAIT
from v$session_wait
where SID = ('&1')
/
select SID, EVENT, P1TEXT, P1, P2TEXT, P2, P3TEXT, P3, SECONDS_IN_WAIT
from v$session_wait
where SID = ('&1')
/

PROMPT

-- @verwait

set feedback on