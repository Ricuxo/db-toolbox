/*  */
col name format a58
set lines 132 pages 45
start title132 'IO Timing Analysis'
spool rep_out\&db\io_time
select  f.FILE# ,d.name,PHYRDS,PHYWRTS,READTIM/PHYRDS,WRITETIM/PHYWRTS
from v$filestat f, v$datafile d
where f.file#=d.file#
order by readtim/phyrds desc
/

spool off

