--******************************************************************************
--*
--*  Description
--*  ***********
--*
--*  File:    get_temp_usage_by_tablespace.sql
--*
--*  Description: This script shows temp tablespace usage metrics for the
--*               current database.
--*
--* ----------------------------------------------------------------------------
--* Date         Author             Description
--* ===========  =================  ============================================
--* 27-JAN-2009  Jeff Moss          Created
--*

set linesize 130
set feed off
set timing off
set wrap on

column "Tablespace" for a30
column "Mb Used"    for 999,999,990
column "Mb Free"    for 999,999,990
column "Mb Total"   for 999,999,990
column "pct used" for 990.90

Prompt '----------------------------------------------'
Prompt  Temporary Tablespace Usage from V$Sort_Segment
Prompt '----------------------------------------------'

SELECT A.tablespace_name tablespace
     , SUM (A.used_blocks * D.block_size) / 1024 / 1024 "Mb Used"
     , D.mb_total - SUM (A.used_blocks * D.block_size) / 1024 / 1024 "Mb Free"
     , D.mb_total      "Mb Total"
     , ((SUM (A.used_blocks * D.block_size) / 1024 / 1024)/d.mb_total)*100 "Pct Used"
  FROM v$sort_segment A
     , ( SELECT B.name
              , C.block_size
              , SUM (C.bytes) / 1024 / 1024 mb_total
           FROM v$tablespace B
              , v$tempfile C
          WHERE B.ts# = C.ts#
          GROUP BY B.name
              , C.block_size
       ) D
 WHERE A.tablespace_name = D.name
 GROUP by A.tablespace_name, D.mb_total
;
Prompt
Prompt '---------------------------------------------------'
Prompt  Temporary Tablespace Usage from V$Temp_Space_Header
Prompt '---------------------------------------------------'

SELECT tablespace_name tablespace
     , SUM(bytes_used) / 1024 / 1024 "Mb Used"
     , SUM(bytes_free) / 1024 / 1024 "Mb Free"
     , (SUM(bytes_used) + SUM(bytes_free)) / 1024 / 1024 "Mb Total"
     , (SUM(bytes_used) / (SUM(bytes_used) + SUM(bytes_free))) * 100 "Pct Used"
FROM   V$temp_space_header
GROUP  BY tablespace_name;


Prompt
Prompt '-------------------------------'
Prompt  Session Using Temporary Segment
Prompt '-------------------------------'
column sid_serial for a15
column username for a10 trunc
column osuser   for a10 trunc
column module   for a20 trunc
column program  for a20 trunc
column tablespace for a20 trunc
column mb_used  for 99,999,990.90

break on report
compute sum of mb_used on report
SELECT S.sid || ',' || S.serial# sid_serial
     , P.spid
     , S.username
     , S.osuser
--     , S.module
     , S.program
     , T.tablespace
     , SUM (T.blocks) * TBS.block_size / 1024 / 1024 mb_used
     , COUNT(*) sort_ops
  FROM v$sort_usage T
     , v$session S
     , dba_tablespaces TBS
     , v$process P
 WHERE T.session_addr = S.saddr
   AND S.paddr = P.addr
   AND T.tablespace = TBS.tablespace_name
 GROUP BY S.sid
        , S.serial#
        , P.spid
        , S.username
        , S.osuser
--        , S.module
        , S.program
        , TBS.block_size
        , T.tablespace
 ORDER BY sid_serial
;

Prompt
Prompt Statement Using Temporary Segment
SELECT S.sid || ',' || S.serial# sid_serial
     , S.username
     , T.blocks * TBS.block_size / 1024 / 1024 mb_used
     , T.tablespace
     , T.sqladdr address
     , Q.hash_value
     , Q.sql_text
  FROM v$sort_usage T
     , v$session S
     , v$sqlarea Q
     , dba_tablespaces TBS
 WHERE T.session_addr = S.saddr
   AND T.sqladdr = Q.address (+)
   AND T.tablespace = TBS.tablespace_name
 ORDER BY S.sid
;

TTITLE Center 'Current Temp Usage' -
skip Center '~~~~~~~~~~~~~~~~~~' -
skip 1 Left 'Temp Tablespace: ' ts_name -
skip 2 -

SELECT /*+ ORDERED */ u.tablespace
     , s.sid || ',' || s.serial# as sid_ser
     , s.username
     , s.osuser
     , (SUM(u.blocks)*TO_NUMBER(a.value))/1048576 as blk_mb
     , x.sql_text
     , s.module || ':' || chr(10) ||'. ' || s.action as process
  FROM v$sort_usage u
     , v$session S
     , v$sql X
     , v$parameter a
 WHERE s.saddr = u.session_addr
   AND s.sql_address = x.address
   AND s.sql_hash_value = x.hash_value
   AND a.name = 'db_block_size'
 GROUP BY u.tablespace
        , s.sid
        , s.serial#
        , s.username
        , s.osuser
        , a.value
        , x.sql_text
        , s.module
        , s.action
 ORDER BY u.tablespace
        , s.sid
/

column Temp_Blks_Total  format 999,999,999,999
column Temp_Blks_Used   format 999,999,999,999
column Pct_Temp_Used    format 990.90

select d.tot "Temp_Blks_Total"
     , u.tot "Temp_Blks_Used"
     , 100*(u.tot/d.tot) "Pct_Temp_Used"
  FROM (select sum(u.blocks) tot from v$tempseg_usage u) u
     , (select sum(d.blocks) tot from dba_temp_files d) d
/
