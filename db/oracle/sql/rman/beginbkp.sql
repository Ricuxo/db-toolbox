Rem
Rem    NOME
Rem      beginbkp.sql  
Rem
Rem    DESCRIÇÃO
Rem      Este script coloca as tablespaces do banco em begin backup.
Rem      
Rem    UTILIZAÇÃO
Rem      @beginbkp
Rem
Rem    ATUALIZAÇÕES  (MM/DD/YY)
Rem     FERR@RI       26/01/07 - criação do script
Rem
Rem ---------- ---------- ---------- ---------- ---------- ---------- ---------- ----------

select 'alter tablespace '||tablespace_name||' begin backup;' as "Coloca as TBS em Begin Backup" 
from dba_tablespaces
order by 1
/

PROMPT Comando: alter database begin backup;
PROMPT