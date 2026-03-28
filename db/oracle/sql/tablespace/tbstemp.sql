--break on TABLESPACE skip 1 nodup
col TABLESPACE for a30
col DATAFILE   for a70
set lines 500


select t.NAME as TABLESPACE,
       d.NAME as DATAFILE,
       d.bytes/1024/1024 as MB,
       d.STATUS,                 
       d.ENABLED,                
       d.CREATE_BYTES,           
       d.BLOCK_SIZE,
       to_char(d.CREATION_TIME,'dd/mm/yyyy hh:mm:ss')
from V$TABLESPACE t, V$TEMPFILE d
where t.TS#=d.TS#
order by 1, 2
/

PROMPT
