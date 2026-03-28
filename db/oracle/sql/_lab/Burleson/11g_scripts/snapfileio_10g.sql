/*  */
-- *************************************************
--  
-- This script is free for non-commercial purposes
-- with no warranties.  Use at your own risk.
--
-- To license this script for a commercial purpose,
-- contact info@rampant.cc
-- *************************************************
rem 
rem NAME: snapfileio.sql

rem FUNCTION: Reports on the file io status of all of the
rem FUNCTION: datafiles in the database for a single snapshot.


column sum_io1 new_value st1 noprint
column sum_io2 new_value st2 noprint
column sum_io new_value divide_by noprint
column Percent format 999.999 heading 'Percent|Of IO'
column brratio format 999.99 heading 'Block|Read|Ratio'
column bwratio format 999.99 heading 'Block|Write|Ratio'
column phyrds heading 'Physical | Reads'
column phywrts heading 'Physical | Writes'
column phyblkrd heading 'Physical|Block|Reads'
column phyblkwrt heading 'Physical|Block|Writes'
column filename format a45 heading 'File|Name'
column file# format 9999 heading 'File'

set feedback off verify off lines 132 pages 60 sqlbl on trims on

select
	nvl(sum(a.phyrds+a.phywrts),0) sum_io1
from 
	dba_hist_filestatxs a where snap_id=&&snap;
  
select nvl(sum(b.phyrds+b.phywrts),0) sum_io2
from
        dba_hist_tempstatxs b where snap_id=&&snap;
        
select &st1+&st2 sum_io from dual;

rem
@title132 'Snap&&snap File I/O Statistics Report'

spool rep_out\&db\fileio&&snap

select
	a.filename, a.phyrds, a.phywrts,
	(100*(a.phyrds+a.phywrts)/&divide_by) Percent,
	a.phyblkrd, a.phyblkwrt, (a.phyblkrd/greatest(a.phyrds,1)) brratio,
      (a.phyblkwrt/greatest(a.phywrts,1)) bwratio
from
	dba_hist_filestatxs a
where
	a.snap_id=&&snap 
union
select
	c.filename, c.phyrds, c.phywrts,
	(100*(c.phyrds+c.phywrts)/&divide_by) Percent,
	c.phyblkrd, c.phyblkwrt,(c.phyblkrd/greatest(c.phyrds,1)) brratio,
      (c.phyblkwrt/greatest(c.phywrts,1)) bwratio
from
	dba_hist_tempstatxs c
where
	c.snap_id=&&snap
order by
	1
/

spool off
pause Press enter to continue
set feedback on verify on lines 80 pages 22
clear columns
ttitle off
undef snap
