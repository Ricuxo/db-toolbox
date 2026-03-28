set lines 120 pages 1000
SELECT x2.TIPO, x2.SID, x2.ID1
 from (SELECT x.TIPO, x.SID, x.ID1
         FROM (select decode(block, 1, 'BLOCK', '    WAIT') TIPO, sid, L.ID1
                 from V$LOCK L
                WHERE L.TYPE='TX'
                AND   L.ID1 IN (select L1.ID1 from v$lock L1 
                                 where L1.type='TX' AND L1.BLOCK=1)
                AND   ROWNUM < 50
               ) x
         WHERE ROWNUM < 50
      ) x2
order by ID1, TIPO DESC;
