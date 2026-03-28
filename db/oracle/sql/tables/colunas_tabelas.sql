Rem
Rem    NOME
Rem      columns.sql  
Rem
Rem    DESCRIÇÃO
Rem      Este script lista as colunas de uma tabela.
Rem      
Rem    UTILIZAÇÃO
Rem      @columns <owner> <table_name>
Rem
Rem    ATUALIZAÇÕES  (MM/DD/YY)
Rem      FERR@RI      05/05/08 - criação do script
Rem
Rem ---------- ---------- ---------- ---------- ---------- ---------- ---------- ----------

prompt
prompt ************************************************************************************
prompt **
prompt *** Lista de colunas da tabela &1 &2
prompt **
prompt ************************************************************************************

set verify off

column column_name    format a30
column DATA_LENGTH    format 999999
column DATA_TYPE      format a10
column PRECISION      format 999999
column SCALE          format a5
column NULLABLE       format a8
column NUM_DISTINCT   format 99999999999
column LAST_ANALYZED  format a18

select column_name    ,
       DATA_TYPE      ,
       decode(NULLABLE,'Y',null,'NOT NULL') nullable,
       case DATA_TYPE 
         when 'DATE' then null
         when 'NUMBER' then null
       else
         DATA_LENGTH
       end DATA_LENGTH,
       case DATA_TYPE
          when 'VARCHAR2' then DATA_LENGTH
       else
          DATA_PRECISION
       end PRECISION ,
       case DATA_SCALE
         when 0 then NULL
       else 
         to_char(DATA_SCALE)
       end SCALE,
       NUM_DISTINCT   ,
       to_char(LAST_ANALYZED,'dd/mm/rr hh24:mi:ss') last_analyzed 
from  dba_tab_columns    
where    owner = upper('&1')
and table_name = upper('&2')
order by 1
/

select tablespace_name,
       num_rows,
       initial_extent,
       next_extent,
       pct_increase,
       num_rows,
       blocks,
       logging
from dba_tables
where    owner = upper('&1')
and table_name = upper('&2')
/
