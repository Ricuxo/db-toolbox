--List all tablespaces with free space < 10%
set pagesize 300
set linesize 100
column tablespace_name format a15 heading 'Tablespace'
column sumb format 999,999,999
column extents format 9999
column bytes format 999,999,999,999
column largest format 999,999,999,999
column Tot_Size format 999,999 Heading 'Total Size(Mb)'
column Tot_Free format 999,999,999 heading 'Total Free(Kb)'
column Pct_Free format 999.99 heading '% Free'
column Max_Free format 999,999,999 heading 'Max Free(Kb)'
column Min_Add format 999,999,999 heading 'Min space add (MB)'

ttitle center 'Tablespaces With Less Than 10% Free Space' skip 2
set echo off

select a.tablespace_name,sum(a.tots/1048576) Tot_Size,
sum(a.sumb/1024) Tot_Free,
sum(a.sumb)*100/sum(a.tots) Pct_Free,
ceil((((sum(a.tots) * 15) - (sum(a.sumb)*100))/85 )/1048576) Min_Add
from
(
select tablespace_name,0 tots,sum(bytes) sumb
from dba_free_space a
group by tablespace_name
union
select tablespace_name,sum(bytes) tots,0 from
dba_data_files
group by tablespace_name) a
group by a.tablespace_name
having sum(a.sumb)*100/sum(a.tots) < 10
order by pct_free;
