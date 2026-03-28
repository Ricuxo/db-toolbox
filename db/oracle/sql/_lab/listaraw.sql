set linesize 200
set pagesize 1000
col file_name format a60
select tablespace_name,file_name,bytes/1024/1024
from dba_data_files
where file_name  like '%&raw%'
/
