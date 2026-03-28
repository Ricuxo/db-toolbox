set linesize 200
set pagesize 1000
col osuser format a10
col sess format a15
col username format a10
col DSLMODE format a12
select a.*, b.serial#, b.username, substr(b.osuser,1,10) osuser, decode(b.status,'ACTIVE','A','I') status
  from (
SELECT   DECODE (request, 0, 'Holder: ', 'Waiter: ') || SID sess,
         id1,
         id2,
         lmode,
         DECODE (lmode,
                 0, 'None',
                 1, 'Null',
                 2, 'Row Share',
                 3, 'Row Exlusive',
                 4, 'Share',
                 5, 'Sh/Row Exlusive',
                 6, 'Exclusive'
                ) dslmode,
         request,
         DECODE (request,
                 0, 'None',
                 1, 'Null',
                 2, 'Row Share',
                 3, 'Row Exlusive',
                 4, 'Share',
                 5, 'Sh/Row Exlusive',
                 6, 'Exclusive'
                ) dsrequest,
         TYPE, sid
    FROM v$lock
   WHERE (id1, id2, TYPE) IN (SELECT id1,
                                     id2,
                                     TYPE
                                FROM v$lock a
                               WHERE a.request > 0)) a,
v$session b
where a.sid = b.sid
order by id1, request
/
