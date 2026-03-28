Rem
Rem    NOME
Rem      flashdrop.sql 
Rem
Rem    DESCRIÇÃO
Rem      Este script verifica as informações de uma determinada tabela dropada, dentro da Recycle Bin
Rem    UTILIZAÇÃO
Rem      @flashdrop <owner> <table>
Rem
Rem    ATUALIZAÇÕES  (MM/DD/YY)
Rem      FERR@RI      09/07/08 - criação do script
Rem
Rem ---------- ---------- ---------- ---------- ---------- ---------- ---------- ----------

set pages 30
set verify off
set feedback off

col owner for a10
col CAN_UNDROP for a11             
col CAN_PURGE  for a11     

select OWNER,                  
       OBJECT_NAME,            
       ORIGINAL_NAME,          
       OPERATION,              
       TYPE as object_type,
       (select VALUE from v$parameter where NAME = 'db_block_size')*SPACE/ 1024 TAM_KB, 
       CAN_UNDROP,             
       CAN_PURGE,    
       TS_NAME,                
       CREATETIME,             
       DROPTIME,               
       DROPSCN,                
       PARTITION_NAME,        
       RELATED,                
       BASE_OBJECT,            
       PURGE_OBJECT,           
       SPACE as space_blocks
from DBA_RECYCLEBIN
where OWNER       = upper('&1')                  
and ORIGINAL_NAME = upper('&2')             
/

PROMPT
PROMPT
set heading off

PROMPT Comandos:
select 'flashback table "'||OBJECT_NAME|| '" to before drop rename to <TABLE_NAME>;'
from DBA_RECYCLEBIN
where OWNER       = upper('&1')                  
and ORIGINAL_NAME = upper('&2')             
/
select 'flashback table "'||OBJECT_NAME|| '" to before drop;'
from DBA_RECYCLEBIN
where OWNER       = upper('&1')                  
and ORIGINAL_NAME = upper('&2')             
/

PROMPT
PROMPT 
set heading on
set verify on
set feedback on
set pages 1000