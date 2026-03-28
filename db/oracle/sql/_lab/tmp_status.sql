set linesize 200
set feed off
set timing off
set wrap on

Prompt
Prompt +-------------------------------+
Prompt  Session Using Temporary Segment
Prompt +-------------------------------+
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

column "Tablespace" for a30
column "Mb Used"    for 999,999,990
column "Mb Free"    for 999,999,990
column "Mb Total"   for 999,999,990
column "pct used"   for 990.90

Prompt
Prompt +----------------------------------------------+
Prompt  Temporary Tablespace Usage from V$Sort_Segment
Prompt +----------------------------------------------+

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
Prompt +---------------------------------------------------+
Prompt  Temporary Tablespace Usage from V$Temp_Space_Header
Prompt +---------------------------------------------------+

SELECT tablespace_name tablespace
     , SUM(bytes_used) / 1024 / 1024 "Mb Used"
     , SUM(bytes_free) / 1024 / 1024 "Mb Free"
     , (SUM(bytes_used) + SUM(bytes_free)) / 1024 / 1024 "Mb Total"
     , (SUM(bytes_used) / (SUM(bytes_used) + SUM(bytes_free))) * 100 "Pct Used"
FROM   V$temp_space_header
GROUP  BY tablespace_name;

PROMPT 
PROMPT +------------------------------------------------------------------------+
PROMPT | Report   : Temporary Sort Segments                                     |
PROMPT +------------------------------------------------------------------------+

COLUMN instance_name              FORMAT a8                 HEADING 'Instance'
COLUMN tablespace_name            FORMAT a15                HEADING 'Tablespace|Name'          JUST right
COLUMN temp_segment_name          FORMAT a8                 HEADING 'Segment|Name'             JUST right
COLUMN current_users              FORMAT 9,999              HEADING 'Current|Users'            JUST right
COLUMN total_temp_segment_size    FORMAT 999,999,999,999    HEADING 'Total Temp|Segment Size'  JUST right
COLUMN currently_used_bytes       FORMAT 999,999,999,999    HEADING 'Currently|Used Bytes'     JUST right
COLUMN pct_used                   FORMAT 999                HEADING 'Pct.|Used'                JUST right
COLUMN extent_hits                FORMAT 999,999,999        HEADING 'Extent|Hits'              JUST right
COLUMN max_size                   FORMAT 999,999,999,999    HEADING 'Max|Size'                 JUST right
COLUMN max_used_size              FORMAT 999,999,999,999    HEADING 'Max Used|Size'            JUST right
COLUMN max_sort_size              FORMAT 999,999,999,999    HEADING 'Max Sort|Size'            JUST right
COLUMN free_requests              FORMAT 999                HEADING 'Free|Requests'            JUST right

BREAK ON instance_name SKIP PAGE

SELECT
    i.instance_name               instance_name
  , t.tablespace_name             tablespace_name
  , 'SYS.'          || 
    t.segment_file  ||
    '.'             || 
    t.segment_block               temp_segment_name
  , t.current_users               current_users
  , (t.total_blocks*b.value)      total_temp_segment_size
  , (t.used_blocks*b.value)       currently_used_bytes
  , TRUNC(ROUND((t.used_blocks/t.total_blocks)*100))    pct_used
  , t.extent_hits                 extent_hits
  , (t.max_blocks*b.value)        max_size
  , (t.max_used_blocks*b.value)   max_used_size
  , (t.max_sort_blocks *b.value)  max_sort_size
  , t.free_requests               free_requests
FROM
    gv$instance                     i
  , gv$sort_segment                 t
  , (select value from v$parameter
     where name = 'db_block_size')  b
WHERE
    t.inst_id = i.inst_id
ORDER BY
    i.instance_name
  , t.tablespace_name
/

PROMPT 
PROMPT +------------------------------------------------------------------------+
PROMPT | Report   : DBA_TEMPORARY_FREE_SPACE                                    |
PROMPT +------------------------------------------------------------------------+
@dtfs

Prompt
Prompt

@reset