/*  */
column today noprint new_value xdate
select substr(to_char(sysdate,'fmMonth DD, YYYY HH:MI:SS P.M.'),1,35) today
from dual;
column name noprint new_value dbname
column created noprint new_value dbcreated
column host_name noprint new_value hostname
column instance_name noprint new_value instname
select name,created from v$database;
select host_name from v$instance;
select instance_name from v$instance;

set pagesize 59
set linesize 132
set echo off
set feedback off
set termout off

spool &instname..&dbname..&hostname..db_extent_usage.out

prompt Date:      &xdate
prompt DATABASE:  &dbname
prompt INSTANCE:  &instname
prompt HOST:      &hostname
prompt Created:   &dbcreated
prompt

column "Kbytes"	format 99,999,999;
column "Mbytes"	format 99,999.99;
column "NextBlock" format 9999999;
column tablespace_name	format a20;
column segment_name format a25;
column file_id format 999;

ttitle left 'Database Extent Usage Report' skip 1 -
left 'Page: ' format 99  sql.pno skip 2

break on report -
	on tablespace_name skip 1 -

compute count of block_id on tablespace_name;
compute sum max of "Blocks" "Kbytes" "Mbytes" on tablespace_name;
compute sum of "Kbytes" "Mbytes" on report;

select tablespace_name,file_id,segment_name,
bytes, bytes/1024 as "Kbytes", bytes/1024/1024 as "Mbytes", 
block_id, blocks, block_id+blocks as "NextBlock"
from dba_extents
union 
select tablespace_name,file_id,'***** FREE *****' ,
bytes, bytes/1024 as "Kbytes", bytes/1024/1024 as "Mbytes", 
block_id, blocks, block_id+blocks as "NextBlock"
from dba_free_space
order by tablespace_name,file_id,block_id;

spool off
quit

