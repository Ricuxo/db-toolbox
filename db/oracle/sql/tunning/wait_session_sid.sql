select event, time_waited as time_spent
from v$session_event
where sid = &sid
and event not in (
'Null event',
'client message',
'KXFX: Execution Message Dequeue – Slave',
'PX Deq: Execution Msg',
'KXFQ: kxfqdeq – normal deqeue',
'PX Deq: Table Q Normal',
'Wait for credit – send blocked',
'PX Deq Credit: send blkd',
'Wait for credit – need buffer to send',
'PX Deq Credit: need buffer',
'Wait for credit – free buffer',
'PX Deq Credit: free buffer',
'parallel query dequeue wait',
'PX Deque wait',
'Parallel Query Idle Wait – Slaves',
'PX Idle Wait',
'slave wait',
'dispatcher timer',
'virtual circuit status',
'pipe get', 'rdbms ipc message',
'rdbms ipc reply',
'pmon timer',
'smon timer',
'PL/SQL lock timer',
'SQL*Net message from client',
'WMON goes to sleep')
union all
select b.name, a.value
from v$sesstat a, v$statname b
where a.statistic# = b.statistic#
and b.name = 'CPU used when call started'
and a.sid = &sid;
