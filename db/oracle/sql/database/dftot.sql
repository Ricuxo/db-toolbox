Rem
Rem    NOME
Rem      dftot.sql 
Rem
Rem    DESCRIÇÃO
Rem      Este script verifica qual o tamanho total da base de dados em GB.
Rem
Rem    UTILIZAÇÃO
Rem      @dftot
Rem
Rem    ATUALIZAÇÕES  (MM/DD/YY)
Rem      FERR@RI      27/01/07 - criação do script
Rem
Rem ---------- ---------- ---------- ---------- ---------- ---------- ---------- ----------

@cab

set heading off

select 'Espaco ocupado em disco : ' || sum( BYTES ) / 1024 / 1024 /1024 || ' GB'
from (select sum(BYTES) BYTES
      from V$DATAFILE
      union all
      select sum(BYTES) BYTES
      from V$TEMPFILE
      union all
      select sum(BYTES * MEMBERS) BYTES
      from gV$LOG );

set heading on

prompt

