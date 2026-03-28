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
rem NAME: snapdeltafileio.sql
rem
rem FUNCTION: Reports on the file io status of all of 
rem FUNCTION: the datafiles in the database across 
rem FUNCTION: two snapshots.
rem HISTORY:
rem WHO		WHAT		WHEN
rem Mike Ault		Created		11/19/03
rem

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
	nvl(sum((b.phyrds-a.phyrds)+(b.phywrts-a.phywrts)),0) sum_io1
from 
	dba_hist_filestatxs a, dba_hist_filestatxs b 
where 
        a.snap_id=&&first_snap_id and b.snap_id=&&sec_snap_id 
        and a.filename=b.filename;

select
	nvl(sum((b.phyrds-a.phyrds)+(b.phywrts-a.phywrts)),0) sum_io2
from 
	dba_hist_tempstatxs a, dba_hist_tempstatxs b 
where 
        a.snap_id=&&first_snap_id and b.snap_id=&&sec_snap_id 
        and a.filename=b.filename;

select &st1+&st2 sum_io from dual;

rem
@title132 'Snap &&first_snap_id to &&sec_snap_id File I/O Statistics Report'
spool rep_out\&db\fileio'&&first_snap_id'_to_'&&sec_snap_id'

select
	a.filename, b.phyrds -a.phyrds phyrds, b.phywrts-a.phywrts phywrts,
	(100*((b.phyrds-a.phyrds)+(b.phywrts-a.phywrts))/&divide_by) Percent,
	b.phyblkrd- a.phyblkrd phyblkrd, b.phyblkwrt-a.phyblkwrt phyblgwrt,
        ((b.phyblkrd-a.phyblkrd)/greatest((b.phyrds-a.phyrds),1)) brratio,
        ((b.phyblkwrt-a.phyblkwrt)/greatest((b.phywrts-a.phywrts),1)) bwratio
from
	dba_hist_filestatxs a, dba_hist_filestatxs b 
where 
        a.snap_id=&&first_snap_id and b.snap_id=&&sec_snap_id 
        and a.filename=b.filename
union
select
	c.filename, d.phyrds-c.phyrds phyrds, d.phywrts-c.phywrts phywrts,
	(100*((d.phyrds-c.phyrds)+(d.phywrts-c.phywrts))/&divide_by) Percent,
	d.phyblkrd-c.phyblkrd phyblkrd, d.phyblkwrt-c.phyblkwrt phyblgwrt,
        ((d.phyblkrd-c.phyblkrd)/greatest((d.phyrds-c.phyrds),1)) brratio,
        ((d.phyblkwrt-c.phyblkwrt)/greatest((d.phywrts-c.phywrts),1)) bwratio
from
	dba_hist_tempstatxs c, dba_hist_tempstatxs d 
where 
        c.snap_id=&&first_snap_id and d.snap_id=&&sec_snap_id 
        and c.filename=d.filename
order by
	1
/
spool off
pause Press enter to continue
set feedback on verify on lines 80 pages 22
clear columns
ttitle off
undef first_snap_id
undef sec_snap_id
