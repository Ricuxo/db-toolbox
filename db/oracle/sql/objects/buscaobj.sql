Rem
Rem    NOME
Rem      busca.sql  
Rem
Rem    DESCRIÇÃO
Rem      Busca os objetos com o nome especificado.
Rem      
Rem    UTILIZAÇÃO
Rem      @busca <nome_objeto>
Rem
Rem    ATUALIZAÇÕES  (MM/DD/YY)
Rem      FERR@RI      26/01/07 - criação do script
Rem
Rem ---------- ---------- ---------- ---------- ---------- ---------- ---------- ----------

PROMPT
PROMPT    DESCRIÇÃO: Este script busca os objetos com o nome especificado. 

set linesize 2000
set buffer   2000
col OBJECT_NAME for a30
col OWNER       for a15

select OWNER, 
       OBJECT_NAME,
       OBJECT_TYPE,
       STATUS, 
       CREATED,        
       LAST_DDL_TIME, 
       TIMESTAMP     
from DBA_OBJECTS
where OBJECT_NAME like upper('%&1%');
