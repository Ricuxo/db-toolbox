--Verifica o andamento do backup , restore ou recover
set lines 500
COL USERNAME FORMAT A15
COL STATUS FORMAT A8
COL MODULE FORMAT A21
COL MACHINE FORMAT A15
COL DATA_LOGON FORMAT A25
set lines 500
set pages 100

SELECT     A.INST_ID,
                   A.SID, 
                   A.SERIAL#,
                   B.USERNAME,
                   B.STATUS,
                   --B.MACHINE,
                   TO_CHAR(B.LOGON_TIME,'YYYY/MM/DD HH24:MI:SS') DATA_LOGON,
                   B.MODULE,
                   A.CONTEXT,
                   A.SOFAR,
                   A.TOTALWORK,
       ROUND(A.SOFAR/A.TOTALWORK*100,2) "%_COMPLETE"   
FROM   GV$SESSION_LONGOPS A JOIN GV$SESSION B
  ON   A.SID = B.SID
WHERE  A.OPNAME LIKE 'RMAN%'
--AND    A.OPNAME NOT LIKE '%aggregate%'
AND    A.TOTALWORK != 0
--AND    B.MACHINE like 'rdrlnx424%'
AND B.USERNAME='SYS'
AND    A.SOFAR <> A.TOTALWORK
ORDER BY 11;
