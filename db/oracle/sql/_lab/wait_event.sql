col event format a35
col username format a15
col parameter format a70
col seconds_in_wait format 9999999
set linesize 300
SELECT a.sid,b.SQL_HASH_VALUE, decode(a.event, 'latch free', a.event || ' :: ' || substr(c.name,1,20), a.event) event,
       RPAD (p1text, 15, '.')             || ': [' || LPAD (p1, 7, ' ') || ']' || ' ' ||
       RPAD (NVL (p2text, '.'), 7, '.')  || ': [' || LPAD (p2, 7, ' ') || ']' || ' ' ||
       RPAD (NVL (p3text, '.'), 10, '.')  || ': [' || LPAD (p3, 7, ' ') || ']' parameter,
       b.username,a.seconds_in_wait SECONDS
FROM v$session_wait a,
     v$session b,
     v$latch_children c
WHERE a.SID = b.SID
AND a.p1raw = c.addr(+)
and a.event like '%&x%'
AND b.status = 'ACTIVE'
AND a.event != 'rdbms ipc message'
order by 3,2
/
