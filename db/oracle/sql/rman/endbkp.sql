Rem
Rem    NOME
Rem      endbkp.sql  
Rem
Rem    DESCRIÇÃO
Rem      Este script cria coloca as tablespaces do banco em end backup.
Rem      
Rem    UTILIZAÇÃO
Rem      @endbkp
Rem
Rem    ATUALIZAÇÕES  (MM/DD/YY)
Rem     FERR@RI       26/01/07 - criação do script
Rem
Rem ---------- ---------- ---------- ---------- ---------- ---------- ---------- ----------

select 'alter tablespace '||tablespace_name||' end backup;' as "Coloca as TBS em End Backup"
from dba_tablespaces
order by 1
/

PROMPT Comando: alter database end backup;
PROMPT






