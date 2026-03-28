--Script – Datafiles with highest I/O activity
col name format a40
set linesize 140
select * from (
select name,phyrds, phywrts,readtim,writetim
from v$filestat a, v$datafile b
where a.file#=b.file#
order by readtim desc) where rownum <6;
