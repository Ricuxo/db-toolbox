Rem
Rem    NOME
Rem      top_5_io.sql 
Rem
Rem    DESCRIÇÃO
Rem      Este script exibe os 5 objetos com maior I/O no banco de dados
Rem
Rem    UTILIZAÇÃO
Rem      @top_5_io
Rem
Rem    ATUALIZAÇÕES  (MM/DD/YY)
Rem      FERR@RI      31/04/10 - criação do script
Rem
Rem ---------- ---------- ---------- ---------- ---------- ---------- ---------- ----------


------------------------------------------------------------------
-- Statistics Descriptions for Oracle9i R2 - Part Number A96536-02
------------------------------------------------------------------

-- physical reads               Total number of data blocks read from disk. This number equals the value of 
--                              "physical reads direct" plus all reads into buffer cache.

-- physical reads direct        Number of reads directly from disk, bypassing the buffer cache. For example, in high 
--                              bandwidth, data-intensive operations such as parallel query, reads of disk blocks 
--                              bypass the buffer cache to maximize transfer rates and to prevent the premature 
--                              aging of shared data blocks resident in the buffer cache. 

-- physical writes              Total number of data blocks written to disk. This number equals the value of 
--                              "physical writes direct" plus all writes from buffer cache.

-- physical writes direct       Number of writes directly to disk, bypassing the buffer cache 
--                             (as in a direct load operation)



set echo off         
set verify off
set feedback off
set heading on
set pagesize 30
set linesize 200
clear columns


TTITLE LEFT ' ===> SEGMENTS BY PHYSICAL READS <==='   SKIP 2
TTITLE OFF

set heading off

select 'Total Physical Reads since instance Startup: '||sum(VALUE)||' ' as value
from v$segment_statistics
where STATISTIC_NAME = 'physical reads'
group by STATISTIC_NAME
/

select 'Instance Startup: '||to_char(STARTUP_TIME, 'dd/mm/yyyy hh24:mm:ss')||'' from V$INSTANCE
/

set heading on 


col OWNER            format a30
col PHYSICAL_READS   format 999,999,999,999,999

select t1.* 
from (select OWNER, 
             OBJECT_NAME, 
             SUBOBJECT_NAME SUBOBJECT, 
             VALUE as PHYSICAL_READS, 
             ROUND((100* (VALUE / (select sum(VALUE) as value from v$segment_statistics where STATISTIC_NAME = 'physical reads' group by STATISTIC_NAME))),2) PCT_TOTAL,
             OBJECT_TYPE, 
             TABLESPACE_NAME TABLESPACE
      from v$segment_statistics
      where STATISTIC_NAME = 'physical reads'
      order by VALUE desc) t1
where rownum < 16
/


TTITLE LEFT ' ===> SEGMENTS BY PHYSICAL WRITES <==='   SKIP 2
TTITLE OFF

col OWNER            format a12
col PHYSICAL_WRITES  format 999,999,999,999,999

select t1.* 
from (select OWNER, 
             OBJECT_NAME, 
             SUBOBJECT_NAME SUBOBJECT, 
             VALUE as PHYSICAL_WRITES, 
             ROUND((100* (VALUE / (select sum(VALUE) as value from v$segment_statistics where STATISTIC_NAME = 'physical writes' group by STATISTIC_NAME))),2) PCT_TOTAL,
             OBJECT_TYPE, 
             TABLESPACE_NAME TABLESPACE
      from v$segment_statistics
      where STATISTIC_NAME = 'physical writes'
      order by VALUE desc) t1
where rownum < 16
/

    
PROMPT
PROMPT Statistics         Description
PROMPT physical reads     Total number of data blocks read from disk. This number equals the value of "physical reads direct" plus all reads into buffer cache.
PROMPT physical writes    Total number of data blocks written to disk. This number equals the value of "physical writes direct" plus all writes from buffer cache.

BTITLE LEFT 'Thanks for running the report' RIGHT 'Page: ' FORMAT 999 SQL.PNO SKIP 2
BTITLE OFF

PROMPT
        
set verify on
set feedback on
clear columns
