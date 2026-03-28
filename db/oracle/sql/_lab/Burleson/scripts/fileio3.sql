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
column brratio format 999.99 heading 'Block|Read|Ratio'
column bwratio format 999.99 heading 'Block|Write|Ratio'
column phyrds heading 'Physical| Reads' format 99999999
column phywrts heading 'Physical| Writes' format 99999999
column phyblkrd heading 'Physical|Block|Reads' format 99999999
column phyblkwrt heading 'Physical|Block|Writes' format 99999999
column name format a38 heading 'File|Name'
column file# format 9999 heading 'File'
set sqlbl on trims on
select
	a.file#,b.name, a.phyrds, a.phywrts,
	a.phyblkrd, a.phyblkwrt, (a.phyblkrd/greatest(a.phyrds,1)) brratio,
      (a.phyblkwrt/greatest(a.phywrts,1)) bwratio
from
	sys.v_$filestat a, sys.v_$dbfile b
where
        (upper(b.name) like '%TOOL%' or upper(b.name) like '%TEMP%')
        and a.file#=b.file#
union
select
	c.file#,d.name, c.phyrds, c.phywrts,
	c.phyblkrd, c.phyblkwrt,(c.phyblkrd/greatest(c.phyrds,1)) brratio,
      (c.phyblkwrt/greatest(c.phywrts,1)) bwratio
from
	sys.v_$tempstat c, sys.v_$tempfile d
where
	c.file#=d.file#
        and upper(d.name) like '%TEMP%'
order by
	1
/
clear columns

