col event format a35
col username format a15
col parameter format a70
col seconds_in_wait format 9999999
set linesize 300
SELECT a.sid,b.SQL_HASH_VALUE, decode(a.event, 'latch free', a.event || ' :: ' || substr(c.name,1,20), a.event) event,
       RPAD (a.p1text, 15, '.')             || ': [' || LPAD (a.p1, 7, ' ') || ']' || ' ' ||
       RPAD (NVL (a.p2text, '.'), 7, '.')  || ': [' || LPAD (a.p2, 7, ' ') || ']' || ' ' ||
       RPAD (NVL (a.p3text, '.'), 10, '.')  || ': [' || LPAD (a.p3, 7, ' ') || ']' parameter,
       b.username,a.seconds_in_wait SECONDS
FROM v$session_wait a,
     v$session b,
     v$latch_children c
WHERE a.SID = b.SID
AND a.p1raw = c.addr(+)
AND b.status = 'ACTIVE'
AND a.event != 'rdbms ipc message'
AND b.username is not null
order by 3
/
