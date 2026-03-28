/*  */
rem
rem FUNCTION: Create list of all database rollback segments
rem FUNCTION: and their storage defaults
rem
column rollback_seg format a8 heading 'Rollback|Segment'
column tablespace format a10 heading 'Rbks|Tablespace'
column pct format 9990 heading 'Pct|Inc'
column init format 99,999,999 heading 'Init|Ext'
column next format 99,999,999 heading 'Next|Ext'
column min format 999 heading 'Min|Ext'
column max format 9,999 heading 'Max|Ext'
column instance format a3 heading 'Int|Num'
column type heading 'Rbks|Type'
column status heading 'Rbks|Status'
set pages 59 lines 132 feedback off echo off
start title132 'Rollback Storage Parameter Report'
spool rep_out\&db\db_rbks
select segment_name rollback_seg,tablespace_name tablespace, 
initial_extent init,
next_extent next, min_extents min, max_extents max, 
pct_increase pct, status, instance_num Instance,
decode(owner,'SYS','PRIVATE') type
from dba_rollback_segs;
spool off
pause press enter/return to continue
clear columns
set pages 22 lines 80 feedback on echo on
ttitle off
