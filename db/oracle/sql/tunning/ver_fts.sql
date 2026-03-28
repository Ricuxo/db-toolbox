set linesize 132
break on hash_value skip 1 dup
col child_number format 9999    heading 'CHILD'
col operation    format a55
col cost         format 99999
col kbytes       format 999999
col object       format a25
select hash_value,
       child_number,
       lpad(' ',2*depth)||operation||' '||options||decode(id, 0, substr(optimizer,1,
6)||' Cost='||to_char(cost)) operation,
       object_name object,
       cost,
       cardinality,
       round(bytes / 1024) kbytes
from   v$sql_plan
where  hash_value in (select  a.sql_hash_value
                      from    v$session a, v$session_wait b
                      where   a.sid   = b.sid
                      and     b.event = 'db file scattered read')
order by hash_value, child_number, id;

