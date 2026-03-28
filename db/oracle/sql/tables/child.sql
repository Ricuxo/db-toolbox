Rem
Rem    NOME
Rem      child.sql  
Rem
Rem    DESCRIÇÃO
Rem      Este script descobre as tabelas que utilizam uma constraint(PK ou UK) de uma tabela pai.
Rem      
Rem    UTILIZAÇÃO
Rem      @child <constraint_name>
Rem
Rem    ATUALIZAÇÕES  (MM/DD/YY)
Rem      FERR@RI      01/03/08 - criação do script
Rem
Rem ---------- ---------- ---------- ---------- ---------- ---------- ---------- ----------

set verify off

select OWNER, 
       CONSTRAINT_NAME, 
       CONSTRAINT_TYPE, 
       TABLE_NAME, 
       R_OWNER, 
       R_CONSTRAINT_NAME
from dba_constraints
where R_CONSTRAINT_NAME = upper('&1')
/

set verify on