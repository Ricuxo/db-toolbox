col tablespace_name for a25
col file_name for a50

select tablespace_name, file_name, trunc(bytes/1024/1024) MB, autoextensible from dba_data_files
where tablespace_name = '&tablespace_name';