

select
   swh.seq#,
   sess.sid,
   sess.username username,
   swh.event     event, 
   swh.p1, 
   swh.p2
from
   v$session              sess, 
   v$session_wait_history swh
where
   sess.sid = 74
and
   sess.sid = swh.sid
order by 
   swh.seq#;
