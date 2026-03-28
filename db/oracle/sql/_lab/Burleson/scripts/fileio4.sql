/*  */
rem 
rem NAME: fileio.sql
rem
rem FUNCTION: Reports on the file io status of all of the
rem FUNCTION: datafiles in the database.

rem HISTORY:
rem WHO		WHAT		WHEN
rem Mike Ault		Created		1/5/96
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
column name format a45 heading 'File|Name'
column file# format 9999 heading 'File'
break on report
compute avg of brratio on report
compute avg of bwratio on report
set feedback off verify off lines 132 pages 60 sqlbl on trims on
rem
select
	nvl(sum(a.phyrds+a.phywrts),0) sum_io1
from 
	sys.v_$filestat a;
select nvl(sum(b.phyrds+b.phywrts),0) sum_io2
from
        sys.v_$tempstat b;
select &st1+&st2 sum_io from dual;
rem
@title132 'File IO Statistics Report'
spool rep_out\&db\fileio
select
	a.file#,b.name, a.phyrds, a.phywrts,
	(100*(a.phyrds+a.phywrts)/&divide_by) Percent,
	a.phyblkrd, a.phyblkwrt, (a.phyblkrd/greatest(a.phyrds,1)) brratio,
      (a.phyblkwrt/greatest(a.phywrts,1)) bwratio
from
	sys.v_$filestat a, sys.v_$dbfile b
where
	a.file#=b.file#
       and (100*(a.phyrds+a.phywrts)/&divide_by)>.0006
union
select
	c.file#,d.name, c.phyrds, c.phywrts,
	(100*(c.phyrds+c.phywrts)/&divide_by) Percent,
	c.phyblkrd, c.phyblkwrt,(c.phyblkrd/greatest(c.phyrds,1)) brratio,
      (c.phyblkwrt/greatest(c.phywrts,1)) bwratio
from
	sys.v_$tempstat c, sys.v_$tempfile d
where
	c.file#=d.file#
    and (100*(c.phyrds+c.phywrts)/&divide_by)>0.0006
order by
	2
/
spool off
pause Press enter to continue
set feedback on verify on lines 80 pages 22
clear columns
ttitle off
