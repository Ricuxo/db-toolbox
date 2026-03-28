Rem
Rem    NOME
Rem      flashvq.sql 
Rem
Rem    DESCRIÇÃO
Rem      Este script ajuda a alterar uma consulta, usando pseudocolunas 
Rem      p/ exibir os valores que uma coluna já possui.
Rem   
Rem    UTILIZAÇÃO
Rem      @flashvq
Rem
Rem    ATUALIZAÇÕES  (MM/DD/YY)
Rem      FERR@RI      09/07/08 - criação do script
Rem
Rem ---------- ---------- ---------- ---------- ---------- ---------- ---------- ----------

set feedback off

col scn_to_timestamp(current_scn) for a40

PROMPT
PROMPT Verificar o SCN atual e seu TIMESTAMP
select current_scn, 
       scn_to_timestamp(current_scn) 
from v$database
/

PROMPT
PROMPT
PROMPT Utilize a consulta abaixo!
PROMPT --------------------------

PROMPT
PROMPT select to_char(versions_starttime,'DD-MON-YYYY HH:MI:SS') "START DATE",
PROMPT        to_char (versions_endtime, 'DD-MON-YYYY HH:MI:ss') "END DATE",
PROMPT        versions_xid,
PROMPT        versions_operation,
PROMPT  mudar colunas ->      employee,                        
PROMPT  mudar colunas ->      salary                           
PROMPT  mudar tabelas -> from test.t1                            
PROMPT versions between scn minvalue and maxvalue
PROMPT  mudar filtros -> where employee = 'JONES'               
PROMPT /
 
PROMPT
set feedback on