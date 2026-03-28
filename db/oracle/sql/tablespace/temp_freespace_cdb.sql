set line 200 pages 999
column name for a20
column tablespace_name for a15
column "MAXSIZE (MB)" format 999,999,990.00
column "ALLOC (MB)" format 9,999,990.00
select a.con_id,c.name,a.tablespace_name,a.bytes_alloc/(1024*1024) "MAXSIZE (MB)",nvl(a.physical_bytes,0)/(1024*1024) "ALLOC (MB)"
from
(select con_id,tablespace_name, sum(bytes) physical_bytes,sum(decode(autoextensible,'NO',bytes,'YES',maxbytes)) bytes_alloc
from cdb_temp_files group by con_id,tablespace_name ) a,
(select name,con_id from v$containers) c
where a.con_id = c.con_id
order by 1,3;