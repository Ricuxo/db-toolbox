COMPUTE SUM OF time_spent ON REPORT
COMPUTE SUM OF time_spent_minutes ON REPORT
BREAK ON REPORT

SELECT event, time_waited as time_spent, time_waited/100/60 as time_spent_minutes
  FROM v$session_event
 WHERE sid = &&sid
   AND event NOT IN (
   	'Null event',
   	'client message',
   	'KXFX: Execution Message Dequeue - Slave',
   	'PX Deq: Execution Msg',
   	'KXFQ: kxfqdeq - normal dequeue',
   	'PX Deq: Table Q Normal',
   	'Wait for credit - send blocked',
   	'PX Deq Credit: send blkd',
   	'Wait for credit - need buffer to send',
   	'PX Deq Credit: need buffer',
   	'Wait for credit - free buffer',
   	'PX Deq Credit: free buffer',
   	'parallel query dequeue wait',
   	'PX Deque wait',
   	'Parallel Query Idle Wait - Slaves',
   	'PX Idle Wait',
   	'slave wait',
   	'dispatcher timer',
   	'virtual circuit status',
   	'pipe get',
   	'rdbms ipc message',
   	'rdbms ipc reply',
   	'pmon timer',
   	'smon timer',
   	'PL/SQL lock timer',
   	'SQL*Net message message from client',
   	'WMON goes to sleep')
UNION ALL
SELECT b.name, a.value, a.value/100/60 as time_spent_minutes
  FROM v$sesstat a, v$statname b
 WHERE a.statistic# 	= b.statistic#
   AND b.name       	= 'CPU used when call started'
   AND a.sid		= &&sid;
   
UNDEFINE SID
