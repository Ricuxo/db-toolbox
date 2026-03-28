Rem
Rem
Rem Verifica fragmentacao em tabelas
Rem
Rem

set pages 50000 lines 32767
col owner for a12
col "Fragmented size" for a30
col "Actual size" for a30
col "Diference" for a30
col table_name for a40

select owner,table_name,round((blocks*8),2)||'kb' "Fragmented size", 
round((num_rows*avg_row_len/1024),2)||'kb' "Actual size", 
round((blocks*8),2)-round((num_rows*avg_row_len/1024),2)||'kb' "Diference",
((round((blocks*8),2)-round((num_rows*avg_row_len/1024),2))/round((blocks*8),2))*100 -10 "reclaimable space % " 
from dba_tables 
where table_name LIKE '&table_Name' AND OWNER LIKE '&schema_name'
AND NUM_ROWS > 0
ORDER BY 6
/
PROMPT
PROMPT
PROMPT
PROMPT Para correcao de fragmentacao
PROMPT 1. alter table ... move + rebuild indexes
PROMPT 2. export / truncate / import
PROMPT 3. create table as select ( CTAS)
PROMPT 4. dbms_redefinition