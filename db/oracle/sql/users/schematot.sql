Rem
Rem    NOME
Rem      schematot.sql 
Rem
Rem    DESCRIÇÃO
Rem      Lista o tamanho (em MB) somando os segmentos do schema especificado.
Rem
Rem    UTILIZAÇÃO
Rem      @schematot <owner/schema>
Rem
Rem    ATUALIZAÇÕES  (MM/DD/YY)
Rem      FERR@RI      26/01/07 - criação do script
Rem
Rem ---------- ---------- ---------- ---------- ---------- ---------- ---------- ----------



column OBJECT_NAME format a30

prompt 
prompt TAMANHO EM MEGAS:

select trunc(sum(BYTES/1024/1024),0) MB
from DBA_SEGMENTS
where OWNER = upper('&1');

prompt

