
compute sum of mem_MB on report
break on report

SELECT 
       a.module, sn.NAME,
       sum(b.VALUE)/1024/1024 mem_MB
FROM   v$session a, v$sesstat b, v$statname sn
WHERE  a.sid    = b.sid
  and  sn.statistic# = b.statistic#
  and  upper(sn.name) like '%UGA%'
  and  upper(module)  like decode('&1','','%',UPPER('%&1%'))
GROUP BY A.MODULE, sn.NAME
order by 2 asc ,3 desc
/

