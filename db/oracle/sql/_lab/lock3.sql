set pages 10000
set lines 10000
column "B/U" format a3 
COLUMN LOCK_ID1 FORMAT A45 heading "Object Name/Lock ID1" 
column ctime format 999999 
column block format 99999 

SELECT  substr(to_char(l.sid),1,4) "SID", 
				P.spid "SRVR PID", 
        substr(s.type,1,1) "B/U", 
        s.username, s.osuser,
        lo.name, lo.owner#,
        rwo.name, rwo.owner#,
				s.process "CLNT PID", 
				substr(s.machine,1,7) "MACHINE", 
				l.type, 
				DECODE(L.TYPE,'MR','File_ID: '||L.ID1, 
				              'TM', LO.NAME, 
				              'TX','USN: '||to_char(TRUNC(L.ID1/65536))||' RWO: '||nvl(RWO.NAME,'None'),L.ID1
				      ) LOCK_ID1, 
				decode(l.lmode,   0, 'None', 
													1, 'Null', 
													2, 'Row-S (SS)', 
													3, 'Row-X (SX)', 
													4, 'Share', 
													5, 'S/Row-X (SSX)', 
													6, 'Exclusive', 
													substr(to_char(l.lmode),1,13)
						  ) "Locked Mode", 
				decode(l.request, 0, 'None', 
													1, 'Null', 
													2, 'Row-S (SS)', 
													3, 'Row-X (SX)', 
													4, 'Share', 
													5, 'S/Row-X (SSX)', 
													6, 'Exclusive', 
													substr(to_char(l.request),1,13)) "Requested", 
				l.ctime, 
				l.block 
FROM v$process P, v$session S, v$lock l, sys.obj$ lo, sys.obj$ rwo 
WHERE l.type != 'MR' 
AND l.sid = S.sid (+) 
AND S.paddr = P.addr (+) 
AND LO.OBJ#(+) = L.ID1 
AND RWO.OBJ#(+) = S.ROW_WAIT_OBJ# 
order by l.sid; 
