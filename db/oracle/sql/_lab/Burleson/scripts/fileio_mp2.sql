/*  */
column sum_io1 new_value st1 noprint
column sum_io2 new_value st2 noprint
column sum_io new_value divide_by noprint
column name format a40 heading 'Mount Point'
column sum_blk_io format 999,999,999 heading 'Sum|Block IO'
column sum_phy_io format 9,999,999,999 heading 'Sum|Physical IO'
column percent format 999.99
set verify off feedback off sqlbl on 
set lines 132 pages 47
ttitle off
select
	nvl(sum(a.phyrds+a.phywrts),0) sum_io1
from 
	sys.v_$filestat a;
select nvl(sum(b.phyrds+b.phywrts),0) sum_io2
from
        sys.v_$tempstat b;
select &st1+&st2 sum_io from dual;
start title132 'File IO by Mount Point'
spool rep_out\&&db\fileio_mp
select
	substr(b.name,1,35) name, sum(a.phyrds+a.phywrts) sum_phy_io,
	sum((100*(a.phyrds+a.phywrts)/&divide_by)) Percent,
	sum(a.phyblkrd+a.phyblkwrt) sum_blk_io
from
	sys.v_$filestat a, sys.v_$dbfile b
where
	a.file#=b.file#
group by substr(b.name,1,35) 
union
select
	substr(d.name,1,35)||'tmp' name, sum(c.phyrds+c.phywrts) sum_phy_io,
	sum((100*(c.phyrds+c.phywrts)/&divide_by)) Percent,
	sum(c.phyblkrd+c.phyblkwrt) sum_blk_io
from
	sys.v_$tempstat c, sys.v_$tempfile d
where
	c.file#=d.file#
group by substr(d.name,1,35)
order by 1,2
/
spool off

