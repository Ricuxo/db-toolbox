Rem
Rem    NOME
Rem      tab.sql 
Rem
Rem    DESCRIÇÃO
Rem      Este script lista informações da tabela especificada.  
Rem   
Rem    UTILIZAÇÃO
Rem      @tab <owner> <tabela>
Rem
Rem    ATUALIZAÇÕES  (MM/DD/YY)
Rem      FERR@RI      23/11/07 - criação do script
Rem
Rem ---------- ---------- ---------- ---------- ---------- ---------- ---------- ----------

@cab

col LAST_ANALYZED for a18
col MB            for 9999999

SET LINE 1000
select a.CREATED, a.LAST_DDL_TIME, 
       to_char(b.LAST_ANALYZED,'DD/MM/YY hh24:mi:ss') LAST_ANALYZED, 
       b.NUM_ROWS
  from DBA_OBJECTS a, DBA_TABLES b
 where a.OBJECT_TYPE = 'TABLE'
   and a.OWNER       = upper( '&&1' )
   and a.OBJECT_NAME = upper( '&&2' )
   and b.OWNER       = a.OWNER
   and b.TABLE_NAME  = a.OBJECT_NAME;
--
prompt
prompt Armazenamento:
select a.TABLESPACE_NAME, a.BYTES/1024/1024 MB, a.EXTENTS, a.INITIAL_EXTENT / 1024 INITIAL_KB, a.NEXT_EXTENT / 1024 NEXT_KB,
       a.FREELISTS, b.INI_TRANS, b.MAX_TRANS, b.CHAIN_CNT, b.PCT_USED, b.PCT_FREE, b.DEGREE, b.MONITORING
  from DBA_SEGMENTS a, DBA_TABLES b
 where SEGMENT_TYPE = 'TABLE'
   and a.OWNER = upper( '&&1' )
   and a.SEGMENT_NAME = upper( '&&2' )
   and b.OWNER = a.OWNER
   and b.TABLE_NAME = a.SEGMENT_NAME;
--
-- Partições
--
prompt
prompt Partições:
column "Critério de Particionamento:" format a32
select COLUMN_NAME "Critério de Particionamento:"
  from DBA_PART_KEY_COLUMNS
 where OWNER               = upper( '&&1' )
   and NAME                = upper( '&&2' )
   and trim( OBJECT_TYPE ) = 'TABLE'
 order by COLUMN_POSITION;
--
column HIGH_VALUE format a100
select PARTITION_POSITION POS, PARTITION_NAME, TABLESPACE_NAME, HIGH_VALUE, LAST_ANALYZED,
       INI_TRANS, MAX_TRANS, FREELISTS
  from DBA_TAB_PARTITIONS
 where TABLE_OWNER = upper( '&&1' )
   and TABLE_NAME  = upper( '&&2' )
 order by PARTITION_POSITION;
--
-- Sub-partições
--
prompt
prompt Subpartições:
column "Critério de Sub-Partição:" format a32
select COLUMN_NAME "Critério de Sub-Partição:"
  from DBA_SUBPART_KEY_COLUMNS
 where OWNER               = upper( '&&1' )
   and NAME                = upper( '&&2' )
   and trim( OBJECT_TYPE ) = 'TABLE'
 order by COLUMN_POSITION;
--
break on PARTITION_NAME skip 1 nodup
column PARTITION_NAME format a40
column SUBPARTITION_NAME format a40
select a.PARTITION_POSITION || ' - ' || a.PARTITION_NAME PARTITION_NAME,
       b.SUBPARTITION_POSITION || ' - ' || b.SUBPARTITION_NAME SUBPARTITION_NAME, b.TABLESPACE_NAME
  from DBA_TAB_PARTITIONS a, DBA_TAB_SUBPARTITIONS b
 where a.TABLE_OWNER = upper( '&&1' )
   and a.TABLE_NAME  = upper( '&&2' )
   and b.TABLE_OWNER = a.TABLE_OWNER
   and b.TABLE_NAME  = a.TABLE_NAME
   and b.PARTITION_NAME = a.PARTITION_NAME
 order by a.PARTITION_POSITION, b.SUBPARTITION_POSITION;
--
-- Primary Key
--
set heading off
select 'Primary Key:'
  from dual;
set heading on
--
break on PK_CONSTRAINT skip 1 nodup on STATUS nodup on VALIDATED nodup on LAST_CHANGE nodup
column COLUMN_NAME format a32
select a.CONSTRAINT_NAME PK_CONSTRAINT, b.COLUMN_NAME COLUMN_NAME, 
       a.STATUS, a.VALIDATED, a.LAST_CHANGE
  from DBA_CONSTRAINTS a, DBA_CONS_COLUMNS b
 where a.OWNER      = upper( '&&1' )
   and a.TABLE_NAME = upper( '&&2' )
   and a.CONSTRAINT_TYPE = 'P'
   and b.OWNER           = a.OWNER
   and b.TABLE_NAME      = a.TABLE_NAME
   and b.CONSTRAINT_NAME = a.CONSTRAINT_NAME
 order by a.CONSTRAINT_NAME, b.POSITION;
--
-- Índices
--
set heading off
select 'Índices:'
  from dual;
set heading on
--
break on INDEX_NAME skip 1 nodup on PARTICIONADO nodup on UNIQUENESS nodup on STATUS nodup
column INDEX_NAME  format a40
column COLUMN_NAME format a40
column PARTICIONADO format a12
select a.INDEX_OWNER || '.' || a.INDEX_NAME INDEX_NAME,
       a.COLUMN_NAME || decode( a.DESCEND, 'ASC', '', ' (' || a.DESCEND || ')' ) COLUMN_NAME,
       nvl( b.LOCALITY, 'NÃO' ) PARTICIONADO, c.UNIQUENESS, c.STATUS, c.index_type, c.LAST_ANALYZED,
       c.tablespace_name IND_TABLESPACE	
  from DBA_IND_COLUMNS a, DBA_PART_INDEXES b, DBA_INDEXES c
 where a.TABLE_OWNER    = upper( '&&1' )
   and a.TABLE_NAME     = upper( '&&2' )
   and b.OWNER (+)      = a.INDEX_OWNER
   and b.INDEX_NAME (+) = a.INDEX_NAME
   and c.OWNER          = a.INDEX_OWNER
   and c.INDEX_NAME     = a.INDEX_NAME
 order by INDEX_OWNER, INDEX_NAME, COLUMN_POSITION;
clear breaks
--
-- Triggers
--
set heading off
select 'Triggers:'
  from dual;
set heading on
--
column TRIGGER_NAME     format a30
column TRIGGERING_EVENT format a20
select OWNER || '.' || TRIGGER_NAME TRIGGER_NAME, 
       TRIGGERING_EVENT, TRIGGER_TYPE, STATUS
  from DBA_TRIGGERS
 where TABLE_OWNER = upper( '&&1' )
   and TABLE_NAME  = upper( '&&2' )
 order by TABLE_OWNER, TABLE_NAME, OWNER, TRIGGER_NAME;
--
-- Foreign Keys
--
set heading off
select 'Foreign Keys:'
  from dual;
set heading on
--
break on FK_CONSTRAINT skip 1 nodup on TABELA_PAI nodup on R_CONSTRAINT nodup
column TABELA_PAI format a40
select a.CONSTRAINT_NAME FK_CONSTRAINT, b.COLUMN_NAME COLUMN_NAME, 
       a.R_OWNER || '.' || c.TABLE_NAME TABELA_PAI,
       c.CONSTRAINT_TYPE || ' - ' || a.R_CONSTRAINT_NAME R_CONSTRAINT, d.COLUMN_NAME, a.STATUS, a.VALIDATED, a.DELETE_RULE, a.LAST_CHANGE
  from DBA_CONSTRAINTS a, DBA_CONS_COLUMNS b, DBA_CONSTRAINTS c, DBA_CONS_COLUMNS d
 where a.OWNER      = upper( '&&1' )
   and a.TABLE_NAME = upper( '&&2' )
   and a.CONSTRAINT_TYPE = 'R'
   and b.OWNER           = a.OWNER
   and b.TABLE_NAME      = a.TABLE_NAME
   and b.CONSTRAINT_NAME = a.CONSTRAINT_NAME
   and c.OWNER           = a.R_OWNER
   and c.CONSTRAINT_NAME = a.R_CONSTRAINT_NAME
   and d.OWNER           = c.OWNER
   and d.TABLE_NAME      = c.TABLE_NAME
   and d.CONSTRAINT_NAME = c.CONSTRAINT_NAME
   and d.POSITION        = b.POSITION
 order by a.CONSTRAINT_NAME, b.POSITION;
--

