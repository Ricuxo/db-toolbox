Rem
Rem    NOME
Rem      schema.sql 
Rem
Rem    DESCRIÇÃO
Rem      Lista a quantidade de objetos (por tipo) do schema especificado.
Rem
Rem    UTILIZAÇÃO
Rem      @schema <owner/schema>
Rem
Rem    ATUALIZAÇÕES  (MM/DD/YY)
Rem      FERR@RI      26/01/07 - criação do script
Rem
Rem ---------- ---------- ---------- ---------- ---------- ---------- ---------- ----------



select OBJECT_TYPE, count(*) QTD
from DBA_OBJECTS
where OWNER = upper( '&1' )
group by OBJECT_TYPE
/

prompt



