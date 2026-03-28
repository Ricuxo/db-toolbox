-- -----------------------------------------------------------------------------------
-- File Name    : @enq_blocker.sql 
-- Author       : Henrique
-- Description  : Durante um evento de enqueue mostra quem é o causador.Retirado do Livro OWI
-- Call Syntax  : @enq_blocker.sql
--
-- Last Modified: 27/07/2016
-- -----------------------------------------------------------------------------------

select /*+ ordered */
       a.sid         blocker_sid,
       a.username    blocker_username,
       a.serial#,
       a.logon_time,
       b.type,
       b.lmode       mode_held,
       b.ctime       time_held,
       c.sid         waiter_sid,
       c.request     request_mode,
       c.ctime       time_waited
from   v$lock b, v$enqueue_lock c, v$session a
where  a.sid     = b.sid
and    b.id1     = c.id1(+)
and    b.id2     = c.id2(+)
and    c.type(+) = 'TX'
and    b.type    = 'TX'
and    b.block   = 1
order by time_held, time_waited;
