Rem
Rem    NOME
Rem      flashdb.sql 
Rem
Rem    DESCRIÇÃO
Rem      Este script exibe informações da utilização do recurso Flashback Database  
Rem   
Rem    UTILIZAÇÃO
Rem      @flashdb
Rem
Rem    ATUALIZAÇÕES  (MM/DD/YY)
Rem      FERR@RI      09/07/08 - criação do script
Rem
Rem ---------- ---------- ---------- ---------- ---------- ---------- ---------- ----------

set feedback off

PROMPT
PROMPT Verificar se o recurso Flashback está ativado ou não.
select FLASHBACK_ON 
from v$database
/

PROMPT
PROMPT A coluna ESTIMATED_FLASHBACK_SIZE estima o tamanho necessario p/ suportar o atual RETENTION_TARGET 
select OLDEST_FLASHBACK_SCN,           
       OLDEST_FLASHBACK_TIME,          
       FLASHBACK_SIZE,       
       RETENTION_TARGET,                                
       ESTIMATED_FLASHBACK_SIZE 
from gv$flashback_database_log
/

PROMPT
select * 
from gv$flashback_database_logfile
/

PROMPT
select * 
from gv$flashback_database_stat
/

PROMPT

set feedback on