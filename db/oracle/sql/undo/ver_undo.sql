SELECT a.inst_id, a.SID, a.SERIAL#, a.STATUS, b.pid, b.SPID, c.USED_UBLK
FROM gV$SESSION a inner join gv$process b
on (a.paddr = b.addr)
inner join gv$transaction c
on (a.taddr = c.addr)
order by a.status
/

