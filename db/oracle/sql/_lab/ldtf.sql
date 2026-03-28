set pagesize 1000
set linesize 200
col file_name format a60
select file_name,bytes/1024/1024 from dba_data_files where tablespace_name='&tbs' order by 1
/
