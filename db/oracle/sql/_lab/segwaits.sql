Rem
Rem    NOME
Rem      segwaits.sql 
Rem
Rem    DESCRIÇÃO
Rem      Este script verifica qual segmento está ocasionando o determinado evento espera.
Rem
Rem    UTILIZAÇÃO
Rem      @segwaits <"statistic_name">
Rem
Rem    ATUALIZAÇÕES  (MM/DD/YY)
Rem      FERR@RI      07/05/08 - criação do script
Rem
Rem ---------- ---------- ---------- ---------- ---------- ---------- ---------- ----------

col owner for a15
col statistic_name for a25

select OWNER,          
       OBJECT_NAME,
       SUBOBJECT_NAME,
       STATISTIC_NAME,
       VALUE,
       OBJECT_TYPE,    
       TABLESPACE_NAME,
       TS#,            
       OBJ#,           
       DATAOBJ#,       
       STATISTIC#     
from v$segment_statistics
where STATISTIC_NAME = ('&1')
order by VALUE
/
