/*  */
rem
rem Name: mapper.sql
rem Function: create an extent map for a specific tablespace
rem 
rem this procedure is from Kevin Loney's DBA book
rem
rem Mike Ault 7/19/96 Burleson Consulting
rem
set pages 47 lines 132 verify off feedback off
column file_id heading 'File|id'
column value new_value dbblksiz noprint
column meg format 9,999.99
select value from v$parameter where name='db_block_size';
ttitle '&&ts Mapping Report'
spool ts_map
select
'free space' owner,
'      ' object,
file_id,
block_id,
blocks,
(blocks*&dbblksiz)/(1024*1024) meg
from dba_free_space
where tablespace_name=upper('&&ts')
union
select
substr(owner,1,20),
substr(segment_name, 1,32),
file_id,
block_id,
blocks,
(blocks*&dbblksiz)/(1024*1024) meg
from dba_extents
where tablespace_name = upper('&&ts')
order by 3,4;
spool off
undef ts
set pages 22 lines 80 verify on feedback on
clear columns
ttitle off
