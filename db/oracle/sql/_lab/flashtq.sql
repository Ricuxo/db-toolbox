Rem
Rem    NOME
Rem      flashtq.sql 
Rem
Rem    DESCRIÇÃO
Rem      Este script exibe todas as transações de uma tabela a partir de uma data.  
Rem   
Rem    UTILIZAÇÃO
Rem      @flashtq <owner> <tabela>
Rem
Rem    ATUALIZAÇÕES  (MM/DD/YY)
Rem      FERR@RI      09/07/08 - criação do script
Rem
Rem ---------- ---------- ---------- ---------- ---------- ---------- ---------- ----------

PROMPT Definir uma data para a consulta, alterando a query.

select TABLE_OWNER, 
       TABLE_NAME,
       OPERATION,              
       UNDO_SQL,
       LOGON_USER,
       XID,                    
       START_SCN,              
       START_TIMESTAMP,        
       COMMIT_SCN,             
       COMMIT_TIMESTAMP,               
       UNDO_CHANGE#,                     
       ROW_ID 
from flashback_transaction_query
-- where start_timestamp >= to_timestamp ('YYYY-01-01 00:01:00','YYYY-MM-DD HH:MI:SS')
and TABLE_OWNER = upper( '&1' )
and TABLE_NAME  = upper( '&2' )
/

