Rem
Rem    NOME
Rem      tbsfree.sql 
Rem
Rem    DESCRI��O
Rem      Este script lista o nome, tamanho, espa�o usado, espa�o livre,    
Rem      o % de ocupa��o de uma determinada tablespace do banco de dados.
Rem
Rem    UTILIZA��O
Rem      @tbsfree <NOME_DA_TABLESPACE>
Rem
Rem    ATUALIZA��ES  (MM/DD/YY)
Rem      FERR@RI      27/12/06 - cria��o do script
Rem
Rem ---------- ---------- ---------- ---------- ---------- ---------- ---------- ----------

-- @cab
--
set verify off

column TAM_MB format a11
column USADO_MB format a11
column LIVRE_MB format a11
column OCUP_% format a7
column " " format a40
set lines 500
--
select c.TABLESPACE_NAME, c.EXTENT_MANAGEMENT, to_char( nvl( e.TAM, b.TAM ), '9999990.99' ) TAM_MB, 
       to_char( nvl( e.TAM, b.TAM ) - nvl( nvl( d.LIVRE, a.LIVRE ), 0 ), '9999990.99' ) USADO_MB, 
       to_char( nvl( nvl( d.LIVRE, a.LIVRE ), 0 ), '9999990.99' ) LIVRE_MB,
       to_char( round( ( ( nvl( e.TAM, b.TAM ) - nvl( nvl( d.LIVRE, a.LIVRE ), 0 ) ) * 100 ) / nvl( e.TAM, b.TAM ), 2 ), '990.99' ) "OCUP_%",
       rpad( rpad( chr(1), round( ( ( ( nvl( e.TAM, b.TAM ) - nvl( nvl( d.LIVRE, a.LIVRE ), 0 ) ) * 100 ) / nvl( e.TAM, b.TAM ) ) / 2.5 ), chr(1) ) ||
       '_', 40, '_' ) " "
  from DBA_TABLESPACES c,
       --
       ( select TABLESPACE_NAME, sum( BYTES ) / 1024 / 1024 LIVRE
           from DBA_FREE_SPACE
          where TABLESPACE_NAME = upper( '&&1' )
          group by TABLESPACE_NAME ) a,
       --
       ( select TABLESPACE_NAME, ( a.free_BLOCKS * b.VALUE ) / 1024 / 1024 LIVRE
           from V$SORT_SEGMENT a, V$PARAMETER b
          where b.NAME = 'db_block_size'
            and a.TABLESPACE_NAME = upper( '&1' ) ) d,
       --     
       ( select TABLESPACE_NAME, sum( BYTES ) / 1024 / 1024 TAM
           from DBA_DATA_FILES
          where TABLESPACE_NAME = upper( '&1' )
          group by TABLESPACE_NAME ) b,
       --     
       ( select TABLESPACE_NAME, sum( BYTES ) / 1024 / 1024 TAM
           from DBA_TEMP_FILES
          where TABLESPACE_NAME = upper( '&1' )
          group by TABLESPACE_NAME ) e       
       --
 where c.TABLESPACE_NAME     = upper( '&1' )
   and a.TABLESPACE_NAME (+) = c.TABLESPACE_NAME
   and d.TABLESPACE_NAME (+) = c.TABLESPACE_NAME
   and b.TABLESPACE_NAME (+) = c.TABLESPACE_NAME
   and e.TABLESPACE_NAME (+) = c.TABLESPACE_NAME
 order by 4;
prompt
--
set verify on

-- 
