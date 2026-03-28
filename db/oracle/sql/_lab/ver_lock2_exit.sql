set pagesize 10000
set linesize 200
select substr(decode (s.lockwait, NULL,'** BLOCKER','== WAITER') || '...............',1,13) ||
           substr(' - ' || s.sid || '..........',1,9) ||
           substr(' - ' || s.username || '..........................',1,26) ||
           substr(' - ' || p.spid || '............',1,13) ||
           substr(' - ' || s.lockwait || '.............................',1,25) ||
           substr(' - ' || 'kill -9 ' || p.spid || '       ...................',1,25) ||
           substr(' - ' || s.status || '..........',1,11)||
           substr(' - ' || s.sql_hash_value ||'........',1,30)||
           substr(' - ' || s.last_call_et ||'........',1,30) as string_tt
    from ( select unique raddr, saddr, request from v$_lock where request > 0) waiter,
         ( select raddr, saddr, request from v$_lock where request = 0) blocker,
            v$session s,
     v$process p
    where waiter.raddr = blocker.raddr
    and (waiter.saddr= s.saddr or blocker.saddr = s.saddr)
    and (s.paddr = p.addr)
/
exit
