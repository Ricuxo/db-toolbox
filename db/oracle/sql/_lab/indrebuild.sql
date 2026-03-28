Rem
Rem    NOME
Rem      indrebuild.sql  
Rem
Rem    DESCRIÇÃO
Rem      Este script verificar os indices inválidos e gera o comando para rebuild dos mesmos.      
Rem
Rem    UTILIZAÇÃO
Rem      @indrebuild
Rem
Rem    ATUALIZAÇÕES  (MM/DD/YY)
Rem      FERR@RI      03/04/08 - criação do script
Rem
Rem ---------- ---------- ---------- ---------- ---------- ---------- ---------- ----------


select 'alter index '||owner||'.'||index_name||' rebuild ;'
from dba_indexes where status = 'UNUSABLE'
/

select 'alter index '||index_owner||'.'||index_name||' rebuild subpartition '||subpartition_name||';'
from dba_ind_subpartitions where status = 'UNUSABLE'
/

select 'alter index '||index_owner||'.'||index_name||' rebuild partition '||partition_name||';'
from dba_ind_partitions where status = 'UNUSABLE'
/
