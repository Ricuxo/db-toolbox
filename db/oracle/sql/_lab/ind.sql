Rem
Rem    NOME
Rem      ind.sql 
Rem
Rem    DESCRIÇÃO
Rem      Este script lista informações do(s) índice(s) especificado(s).  
Rem   
Rem    UTILIZAÇÃO
Rem      @ind <OWNER> <ÍNDICE>
Rem
Rem    ATUALIZAÇÕES  (MM/DD/YY)
Rem      FERR@RI      23/11/07 - criação do script
Rem
Rem ---------- ---------- ---------- ---------- ---------- ---------- ---------- ----------

@cab
--
select a.CREATED, a.LAST_DDL_TIME, b.LAST_ANALYZED, b.STATUS, b.DISTINCT_KEYS, b.clustering_factor 
  from DBA_OBJECTS a, DBA_INDEXES b
 where a.OBJECT_TYPE = 'INDEX'
   and a.OWNER       = upper( '&&own_ind' )
   and a.OBJECT_NAME = upper( '&&name_ind' )
   and b.OWNER       = a.OWNER
   and b.INDEX_NAME  = a.OBJECT_NAME;
--
col TABLE_NAME  for a60
col COLUMN_NAME for a30
break on TABLE_NAME nodup
select TABLE_OWNER ||'.' || TABLE_NAME TABLE_NAME, COLUMN_NAME, DESCEND ORD
  from DBA_IND_COLUMNS
 where INDEX_OWNER = upper( '&&own_ind' )
   and INDEX_NAME  = upper( '&&name_ind' );
--
clear breaks
--
prompt
prompt Armazenamento:
select a.TABLESPACE_NAME, a.BYTES / 1024 KB, a.EXTENTS, a.INITIAL_EXTENT / 1024 INITIAL_KB, a.NEXT_EXTENT / 1024 NEXT_KB,
       a.FREELISTS, b.INI_TRANS, b.MAX_TRANS, b.PCT_INCREASE, b.PCT_FREE, b.DEGREE
  from DBA_SEGMENTS a, DBA_INDEXES b
 where SEGMENT_TYPE   = 'INDEX'
   and a.OWNER        = upper( '&&own_ind' )
   and a.SEGMENT_NAME = upper( '&&name_ind' )
   and b.OWNER        = a.OWNER
   and b.INDEX_NAME   = a.SEGMENT_NAME;
--
-- Partições
--
prompt
prompt Partições:
column HIGH_VALUE format a100
select PARTITION_POSITION POS, PARTITION_NAME, STATUS, TABLESPACE_NAME, HIGH_VALUE, LAST_ANALYZED,
       INI_TRANS, MAX_TRANS, FREELISTS
  from DBA_IND_PARTITIONS
 where INDEX_OWNER = upper( '&&own_ind' )
   and INDEX_NAME  = upper( '&&name_ind' )
 order by PARTITION_POSITION;
--
-- Sub-partições
--
prompt
prompt Subpartições:
break on PARTITION_NAME skip 1 nodup
column PARTITION_NAME format a40
column SUBPARTITION_NAME format a40
select a.PARTITION_POSITION || ' - ' || a.PARTITION_NAME PARTITION_NAME,
       b.SUBPARTITION_POSITION || ' - ' || b.SUBPARTITION_NAME SUBPARTITION_NAME, 
       b.TABLESPACE_NAME,
       b.STATUS
  from DBA_IND_PARTITIONS a, DBA_IND_SUBPARTITIONS b
 where a.INDEX_OWNER    = upper( '&&own_ind' )
   and a.INDEX_NAME     = upper( '&&name_ind' )
   and b.INDEX_OWNER    = a.INDEX_OWNER
   and b.INDEX_NAME     = a.INDEX_NAME
   and b.PARTITION_NAME = a.PARTITION_NAME
 order by a.PARTITION_POSITION, b.SUBPARTITION_POSITION;
--


UNDEFINE own_ind
UNDEFINE name_ind