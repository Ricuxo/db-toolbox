select a.event,
       a.sid, 
       c.sql_hash_value hash_value,
       decode(d.ktssosegt,
              1,'SORT', 2,'HASH',    3,'DATA',
              4,'INDEX',5,'LOB_DATA',6,'LOB_INDEX',
              null) as segment_type,
       b.tablespace_name,
       b.file_name
from   v$session_wait a, dba_data_files b, v$session c, x$ktsso d
where  c.saddr      = d.ktssoses(+)
and    c.serial#    = d.ktssosno(+)
and    d.inst_id(+) = userenv('instance')
and    a.sid        = c.sid
and    a.p1         = b.file_id
and    a.event      = 'direct path read'
union all
select a.event,
       a.sid,
       d.sql_hash_value hash_value,
       decode(e.ktssosegt,
              1,'SORT', 2,'HASH',    3,'DATA',
              4,'INDEX',5,'LOB_DATA',6,'LOB_INDEX',
              null) as segment_type,
       b.tablespace_name,
       b.file_name
from   v$session_wait a, dba_temp_files b, v$parameter c, 
       v$session d, x$ktsso e
where  d.saddr      = e.ktssoses(+)
and    d.serial#    = e.ktssosno(+)
and    e.inst_id(+) = userenv('instance')
and    a.sid        = d.sid
and    b.file_id    = a.p1 - c.value
and    c.name       = 'db_files'
and    a.event      = 'direct path read'
order by 1,2
/

