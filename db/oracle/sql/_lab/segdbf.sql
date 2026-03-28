Rem
Rem    NOME
Rem      segdbf.sql 
Rem
Rem    DESCRIÇÃO
Rem      Este script lista owner, nome, tipo e dos objetos existentes em um datafile específico.
Rem
Rem    UTILIZAÇÃO
Rem      @segdbf <NOME_DO_DATAFILE>
Rem
Rem    ATUALIZAÇÕES  (MM/DD/YY)
Rem      FERR@RI      03/03/09 - criação do script
Rem
Rem ---------- ---------- ---------- ---------- ---------- ---------- ---------- ----------

col OWNER        for a18
col SEGMENT_NAME for a30
col FILE_NAME    for a80

PROMPT Aguarde! Executando...

select E.OWNER,
       E.SEGMENT_NAME, 
       E.PARTITION_NAME,
       E.SEGMENT_TYPE,      
       E.BYTES/1024/1024 as TAM_MB,
       E.TABLESPACE_NAME,          
       D.FILE_NAME      
from DBA_DATA_FILES D, DBA_EXTENTS E
where  D.FILE_NAME = ('&1')
  and  D.FILE_ID = E.FILE_ID
/
