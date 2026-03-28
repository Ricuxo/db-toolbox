Rem
Rem    NOME
Rem      constraints.sql 
Rem
Rem    DESCRIÇÃO
Rem      este script exibe as restrições de integridade(constraints) de uma determinada tabela.
Rem
Rem    UTILIZAÇÃO
Rem      @constraints <owner> <table_name>
Rem
Rem    ATUALIZAÇÕES  (MM/DD/YY)
Rem      FERR@RI      30/03/08 - criação do script
Rem
Rem ---------- ---------- ---------- ---------- ---------- ---------- ---------- ----------

set verify off
col OWNER for a8

select OWNER,                  
       CONSTRAINT_NAME,        
       CONSTRAINT_TYPE,        
       TABLE_NAME,             
       SEARCH_CONDITION,       
       R_OWNER,                
       R_CONSTRAINT_NAME,
       DELETE_RULE,            
       STATUS,                 
       DEFERRABLE,             
       DEFERRED,               
       VALIDATED
from dba_constraints
where owner = upper('&owner')
and   table_name = upper('&table_name')
order by CONSTRAINT_TYPE
/

col COLUMN_NAME for a30
select OWNER, CONSTRAINT_NAME, TABLE_NAME, COLUMN_NAME, POSITION
from DBA_CONS_COLUMNS
where CONSTRAINT_NAME = '&constraint_name'
/

set verify on