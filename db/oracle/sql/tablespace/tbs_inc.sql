
set verify off
set lines 500
col TABLESPACE format A25
col DATAFILE   format A80
col MBYTES format 999,999,999,999
col MAXBYTES for 999,999,999,999
--
Select d.TABLESPACE_NAME as TABLESPACE,
       d.FILE_NAME AS DATAFILE,
       d.autoextensible,
       d.MAXBYTES/1024/1024 as MB,
       d.BYTES/1024/1024 as MBYTES,
       to_char(v.CREATION_TIME, 'dd-mon-yyyy hh24:mm:ss') as "DATA CRIACAO"
from dba_data_files d, v$datafile v
where d.file_id = v.file#
and d.TABLESPACE_NAME = upper ('&1')
order by  v.CREATION_TIME
/


set verify on
