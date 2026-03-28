SELECT a.SID, a.SERIAL#, a.STATUS, b.pid, b.SPID 
FROM V$SESSION a , v$process b 
WHERE a.paddr = b.addr 
and a.SID = &1