set lin 1000
set verify off
col temporary_tablespace for a20
col TEMPFILE for a60
col data_criação for a12
col MB for 9999,999,999,999,999,999

select a.tablespace_name as temporary_tablespace,
       a.file_name       as tempfile,
                   b.creation_time   as data_criação,
                   a.bytes/1024/1024 as mb
  from dba_temp_files a 
  join v$datafile b
    on a.file_id = b.file#
where a.tablespace_name = upper ('&&tablespace')
order by b.creation_time;
