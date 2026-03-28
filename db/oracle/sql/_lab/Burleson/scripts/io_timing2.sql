/*  */
col name format a58 heading 'Name'
col phywrts heading 'Phys. Writes'
col phyreads heading 'Phys. Reads'
col read_rat heading 'Avg. Read|Time'
col write_rat heading 'Avg. Write|Time'
set lines 132 pages 45
@title132 'IO Timing Analysis'
spool rep_out\&db\io_time
select  f.FILE# ,d.name,PHYRDS,PHYWRTS,READTIM/greatest(PHYRDS,1) read_rat,WRITETIM/greatest(PHYWRTS,1) write_rat
from v$filestat f, v$datafile d
where f.file#=d.file#
union
select  f.FILE# ,d.name,PHYRDS,PHYWRTS,READTIM/greatest(PHYRDS,1) read_rat,WRITETIM/greatest(PHYWRTS,1) write_rat
from v$tempstat f, v$tempfile d
where f.file#=d.file#
order by 5 desc
/
spool off
ttitle off
clear columns
set lines 80 pages 22
