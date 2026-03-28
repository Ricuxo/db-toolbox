col id format a3

select 'aaf' id, a.tablespace_name,
       trunc(a.total,2) mbytes_total,
       nvl(trunc(b.used,2),0)mbytes_used,
       nvl(trunc(a.total-b.used,2),0) mbytes_free,
       nvl(trunc(((a.total-b.used)*100)/a.total,2),100) pct_free,
       0                                        max_free
  from (select tablespace_name, sum(bytes)/1024/1024 total
         from dba_temp_files
        group by tablespace_name) a,
       (select tablespace, sum(blocks*8192)/1024/1024 used
         from v$sort_usage
        group by tablespace) b
 where a.tablespace_name = b.tablespace (+)
ORDER BY 5 desc
/
