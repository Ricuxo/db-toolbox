-- -----------------------------------------------------------------------------------
-- File Name    : @log_file_sync_sess.sql 
-- Author       : Henrique
-- Description  : Verificar sessões que aguardam no evento log file sync.Retirado do Livro OWI
-- Call Syntax  : @log_file_sync_sess.sql
--
-- Last Modified: 27/07/2016
-- -----------------------------------------------------------------------------------

select a.sid,
       a.event,
       a.time_waited,
       a.time_waited / c.sum_time_waited * 100 pct_wait_time,
       d.value user_commits,
       round((sysdate - b.logon_time) * 24) hours_connected
from   v$session_event a, v$session b, v$sesstat d,
       (select sid, sum(time_waited) sum_time_waited
        from   v$session_event
        where  event not in (
                    'Null event',
                    'client message',
                    'KXFX: Execution Message Dequeue - Slave',
                    'PX Deq: Execution Msg',
                    'KXFQ: kxfqdeq - normal deqeue',
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
                    'SQL*Net message from client',
                    'WMON goes to sleep')
        having sum(time_waited) > 0 group by sid) c
where  a.sid         = b.sid
and    a.sid         = c.sid
and    a.sid         = d.sid
and    d.statistic#  = (select statistic# 
                        from   v$statname 
                        where name = 'user commits')
and    a.time_waited > 10000
and    a.event       = 'log file sync'
order by pct_wait_time, hours_connected;