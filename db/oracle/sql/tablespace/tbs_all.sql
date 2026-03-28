column tablespace format a30
column total_mb format 999,999,999,999.99
column used_mb format 999,999,999,999.99
column free_mb format 999,999,999.99
column pct_used format 999.99
column graph format a25 heading "GRAPH (X=5%)"
column status format a10
column ALLOCATION_TYPE format a15
column EXTENT_MANAGEMENT format a17
compute sum of total_mb on report
compute sum of used_mb on report
compute sum of free_mb on report
break on report

set lines 200 pages 100
UNDEFINE 1

select  total.ts tablespace,
        DECODE(total.mb,null,'OFFLINE',dbat.status) status,
	total.mb total_mb,
	NVL(total.mb - free.mb,total.mb) used_mb,
	NVL(free.mb,0) free_mb,
        ALLOCATION_TYPE,
	EXTENT_MANAGEMENT,
	INITIAL_EXTENT,
	NEXT_EXTENT,
	CASE WHEN (total.mb IS NULL) THEN '['||RPAD(LPAD('OFFLINE',13,'-'),20,'-')||']'
	ELSE '['|| DECODE(free.mb,
                             null,'XXXXXXXXXXXXXXXXXXXX',
                             NVL(RPAD(LPAD('X',trunc((100-ROUND( (free.mb)/(total.mb) * 100, 2))/5),'X'),20,'-'),
		'--------------------'))||']' 
         END as GRAPH
from
	(select tablespace_name ts, sum(bytes)/1024/1024 mb from dba_data_files group by tablespace_name) total,
	(select tablespace_name ts, sum(bytes)/1024/1024 mb from dba_free_space group by tablespace_name) free,
        dba_tablespaces dbat
where total.ts=free.ts(+) and
      total.ts=dbat.tablespace_name 
UNION ALL
select  sh.tablespace_name, 
        'TEMP',
	SUM(sh.bytes_used+sh.bytes_free)/1024/1024 total_mb,
	SUM(sh.bytes_used)/1024/1024 used_mb,
	SUM(sh.bytes_free)/1024/1024 free_mb,
        'TEMP' ALLOCATION_TYPE,
	'TEMP' EXTENT_MANAGEMENT,
	0 INITIAL_EXTENT,
	0 NEXT_EXTENT,
        '['||DECODE(SUM(sh.bytes_free),0,'XXXXXXXXXXXXXXXXXXXX',
              NVL(RPAD(LPAD('X',(TRUNC(ROUND((SUM(sh.bytes_used)/SUM(sh.bytes_used+sh.bytes_free))*100,2)/5)),'X'),20,'-'),
                '--------------------'))||']'
FROM v$temp_space_header sh
GROUP BY tablespace_name
order by ALLOCATION_TYPE, tablespace
/
