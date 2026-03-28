
compute sum of PGA_ALLOC_MEM_MB on report
break on report

SELECT 
       a.module,
       sum(b.PGA_ALLOC_MEM)/1024/1024 pga_alloc_mem_MB
FROM   gv$session a, gv$process b
WHERE  a.paddr    = b.addr
AND    a.inst_id  = b.inst_id
GROUP BY A.MODULE
order by 2
/