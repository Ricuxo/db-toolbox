/*  */
rem  **************************************************************************
rem
rem  NAME: ACT_SIZE8.sql
rem
rem  HISTORY:
rem  Date             Who              What
rem  --------  -------------------  ------------------------------------------
rem  09/??/90  Maurice C. Manton    Creation for IOUG
rem  12/23/92  Michael Brouillette  Assume TEMP_SIZE_TABLE exists.Use DBA info.
rem				    Prompt for user name. Spool file = owner.
rem   07/15/96  Mike Ault	Updated for Oracle 7.x
rem   02/24/00  Mike Ault     Updated for Oracle 8.x
rem  FUNCTION:  Will show actual block used vs allocated for all tables for a
rem	        user. 
rem  INPUTS:  owner = Table owner name.
rem  requires temp_size_table table_name (varchar2(64), blocks number)be created.
rem  **************************************************************************
rem accept owner prompt 'Enter table owner name: '
set heading off feedback off verify off echo off recsep off pages 0
column db_block_size new_value blocksize noprint
ttitle off
define cr='chr(10)'
define qt='chr(39)'
delete temp_size_table;
select value db_block_size from v$parameter where name='db_block_size';
SPOOL fill_sz.sql
select 'INSERT INTO temp_size_table'||&&cr||
       'SELECT '||&&qt||segment_name||&&qt||&&cr||
       ',COUNT( DISTINCT( SUBSTR( dbms_rowid.rowid_to_restricted(ROWID,1),1,8))) blocks'||&&cr||
       'FROM '||owner||'.'||segment_name||';'
  FROM dba_segments
 WHERE segment_type ='TABLE' AND owner not in ('SYS','SYSTEM','MDSYS','CTXSYS','OUTLN','Burleson Consulting');
SPOOL OFF
DEFINE temp_var = &&qt;
START fill_sz
HOST del  fill_sz.sql
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
set lines 132
start title132 "Actual Size Report"
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
rem delete temp_size_table;
set termout on feedback 15 verify on pagesize 20 linesize 80 space 1
undef qt
undef cr
ttitle off
clear columns 
clear computes
pause press enter to continue

