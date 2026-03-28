/*  */
rem
rem Name: rollback.sql
rem Purpose: Generate soft documentation for rollback segments on database
rem Limitations: User must have access to dba_rollback_segs
rem:
rem History:
rem Who:	What:		When:
rem M. Ault	Initial Creation	4/18/96
rem
column owner format a10 heading 'Owner'
column tablespace_name format a15 heading 'Tablespace|Name'
column segment_name format a30 heading 'Rollback|Segment Name'
column initial_extent heading 'Initial|Extent'
column next_extent heading 'Next|Extent'
column min_extents heading 'Minimum|Extents'
column max_extents heading 'Maximum|Extents'
column extents heading 'Current|Extents'
column optsize heading 'Optimal|Setting'
set pages 48 lines 130
break on owner on tablespace_name
start title132 "Rollback Segment Report"
spool rep_out\&db\rollback
select 
	owner,
	tablespace_name,
	segment_name ,
	initial_extent,
	next_extent,
	min_extents,
	max_extents,
	extents,
	optsize
from 
	dba_rollback_segs a, sys.v_$rollstat b
where 
	a.segment_id=b.usn
order by 
	owner,
	tablespace_name
/
spool off
set pages 22 lines 80
clear columns
clear breaks
ttitle off
pause Press enter to continue

