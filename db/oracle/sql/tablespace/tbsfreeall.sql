Rem
Rem    NOME
Rem      tbsfreeall.sql 
Rem
Rem    DESCRI��O
Rem      Este script lista o nome, tamanho, espa�o usado, espa�o livre,    
Rem      o % de ocupa��o de todos os tablespaces do banco de dados.
Rem
Rem    UTILIZA��O
Rem      @tbsfreeall
Rem
Rem    ATUALIZA��ES  (MM/DD/YY)
Rem      FERR@RI      03/01/07 - ordenar por ocupa��o% descrescente
Rem      FERR@RI      27/12/06 - cria��o do script
Rem
Rem ---------- ---------- ---------- ---------- ---------- ---------- ---------- ----------

@cab
--
column TAM_MB format a11
column USADO_MB format a11
column LIVRE_MB format a11
column OCUP_% format a7
column " " format a40
set lines 500
--
select c.INITIAL_EXTENT,c.NEXT_EXTENT,c.MIN_EXTENTS,c.MAX_EXTENTS,c.TABLESPACE_NAME, c.EXTENT_MANAGEMENT, to_char( nvl( e.TAM, b.TAM ), '9999990.99' ) TAM_MB,
       to_char( nvl( e.TAM, b.TAM ) - nvl( nvl( d.LIVRE, a.LIVRE ), 0 ), '9999990.99' ) USADO_MB, 
       to_char( nvl( nvl( d.LIVRE, a.LIVRE ), 0 ), '9999990.99' ) LIVRE_MB,
       to_char( round( ( ( nvl( e.TAM, b.TAM ) - nvl( nvl( d.LIVRE, a.LIVRE ), 0 ) ) * 100 ) / nvl( e.TAM, b.TAM ), 2 ), '990.99' ) "OCUP_%",
       rpad( rpad( chr(1), round( ( ( ( nvl( e.TAM, b.TAM ) - nvl( nvl( d.LIVRE, a.LIVRE ), 0 ) ) * 100 ) / nvl( e.TAM, b.TAM ) ) / 2.5 ), chr(1) ) ||'_', 40, '_' ) " "
  from DBA_TABLESPACES c,
       --
       ( select TABLESPACE_NAME, sum( BYTES ) / 1024 / 1024 LIVRE
           from DBA_FREE_SPACE
          group by TABLESPACE_NAME ) a,
       --
       ( select TABLESPACE_NAME, ( a.free_BLOCKS * b.VALUE ) / 1024 / 1024 LIVRE
           from V$SORT_SEGMENT a, V$PARAMETER b
          where b.NAME = 'db_block_size') d,
       --
       ( select TABLESPACE_NAME, sum( BYTES ) / 1024 / 1024 TAM
           from DBA_DATA_FILES
          group by TABLESPACE_NAME ) b,
       --
       ( select TABLESPACE_NAME, sum( BYTES ) / 1024 / 1024 TAM
           from DBA_TEMP_FILES
          group by TABLESPACE_NAME ) e
       --
 where a.TABLESPACE_NAME (+) = c.TABLESPACE_NAME
   and d.TABLESPACE_NAME (+) = c.TABLESPACE_NAME
   and b.TABLESPACE_NAME (+) = c.TABLESPACE_NAME
   and e.TABLESPACE_NAME (+) = c.TABLESPACE_NAME
   order by 10;
prompt
--

