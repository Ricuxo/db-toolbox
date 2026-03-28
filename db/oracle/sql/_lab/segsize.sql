Rem
Rem    NOME
Rem      segsize.sql 
Rem
Rem    DESCRIÇÃO
Rem      Este script lista o owner, o nome, o tamanho e o tipo de segmento
Rem
Rem    UTILIZAÇÃO
Rem      @segsize <OWNER> <SEGMENT_NAME>
Rem
Rem    ATUALIZAÇÕES  (MM/DD/YY)
Rem      FERR@RI      15/05/07 - criação do script
Rem
Rem ---------- ---------- ---------- ---------- ---------- ---------- ---------- ----------

@cab
--
col OWNER for a14
col SEGMENT_NAME for a30
col PARTITION_NAME for a25
--
select OWNER, 
       SEGMENT_NAME, 
       PARTITION_NAME,
       TRUNC(BYTES/1024/1024,0) as MBytes, 
       EXTENTS,        
       SEGMENT_TYPE, 
       TABLESPACE_NAME
from dba_segments
where owner = upper ('&1')
and SEGMENT_NAME = upper('&2')
order by PARTITION_NAME
/

PROMPT
--
