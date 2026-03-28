/*  */
define bs = '&&blocksize K'
COLUMN t_date NOPRINT new_value t_date
COLUMN user_id NOPRINT new_value user_id
COLUMN segment_name FORMAT A25 HEADING "SEGMENT|NAME"
COLUMN segment_type FORMAT A7 HEADING "SEGMENT|TYPE"
COLUMN extents FORMAT 999 HEADING "EXTENTS"
COLUMN kbytes FORMAT 999,999,999 HEADING "KILOBYTES"
COLUMN blocks FORMAT 9,999,999 HEADING "ALLOC.|&&bs|BLOCKS"
COLUMN act_blocks FORMAT 9,999,990 HEADING "USED|&&bs|BLOCKS"
COLUMN pct_block FORMAT 999.99 HEADING "PCT|BLOCKS|USED"
start title132 "Actual Size Report for &owner"
set pages 55
break on report on segment_type skip 1
compute sum of kbytes on segment_type report 
SPOOL rep_out\&db\&owner
SELECT segment_name, segment_type,sum(extents) extents, sum(bytes)/1024 kbytes, 
       sum(a.blocks) blocks,nvl(max(b.blocks),0) act_blocks, 
       (max(b.blocks)/sum(a.blocks))*100 pct_block
  FROM sys.dba_segments a, temp_size_table b
 WHERE segment_name = UPPER( b.table_name )
 GROUP BY segment_name, segment_type
 ORDER BY segment_type,segment_name;
SPOOL OFF
delete temp_size_table;
set termout on feedback 15 verify on pagesize 20 linesize 80 space 1
undef qt
undef cr
ttitle off
clear columns 
clear computes
pause press enter to continue

