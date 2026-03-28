set lines 500
col TEMPFILES for a70
SELECT TABLESPACE_NAME,FILE_NAME as "TEMPFILES",BYTES/1024/1024 as "MB",AUTOEXTENSIBLE
FROM dba_temp_files where tablespace_name= upper ('&&1');