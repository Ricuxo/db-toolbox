----Ver quantidade de memoria PGA alocada 
col SPID for a20
col username for a20
set lines 500

SELECT
    s.username,s.sid,p.spid,pm.*
    --,s.inst_id
FROM 
    v$session s
  , v$process p
  , v$process_memory pm
WHERE
    s.paddr = p.addr
AND p.pid = pm.pid
ORDER BY
ALLOCATED,sid, category
/




-----alto consumo de pga

SELECT s.sid, s.serial#, s.username, pga_used_mem / 1024 / 1024 "PGA_MB"
FROM v$session s, v$process p
WHERE s.paddr = p.addr
ORDER BY pga_used_mem DESC;
