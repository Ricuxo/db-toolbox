Rem
Rem    NOME
Rem      recyclebin.sql 
Rem
Rem    DESCRIÇÃO
Rem      Este script lista informações sobre o conteúdo e tamanho da recycle bin.
Rem    UTILIZAÇÃO
Rem      @recyclebin
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
order by ORIGINAL_NAME
/


PROMPT 
set heading off
select 'Tamanho Total da RECYCLEBIN: ' || trunc(sum((select VALUE from v$parameter where NAME = 'db_block_size')*SPACE/1024/1024),0) || ' Megabytes'
from DBA_RECYCLEBIN
/

PROMPT
PROMPT Comandos:
PROMPT purge table "BIN$ULNd/...";   <- object_name
PROMPT purge tablespace <tablespace_name>
PROMPT purge tablespace <tablespace_name> user <username>
PROMPT purge dba_recyclebin          <- requer SYSDBA

PROMPT

set heading on
set verify on
set feedback on
set pages 1000