SELECT /*+ rule */ DECODE(request,0,'Holder: ','Waiter: ')|| a.sid sess, id1, id2, lmode,
request, a.type,process,b.sid, b.serial#, b.process
   FROM V$LOCK a, v$session b
 WHERE (id1, id2, a.type) IN (SELECT id1, id2, type FROM V$LOCK WHERE request>0)
and a.sid=b.sid
   ORDER BY id1, request
/
