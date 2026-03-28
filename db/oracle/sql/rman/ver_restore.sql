--Verifica o andamento do backup , restore ou recover
set linesize 180
set pagesize 20
alter session set NLS_DATE_FORMAT='DD-MON-YYYY HH24MISS';

SELECT
'DUPLICATE/RESTORE THROUGHPUT',
round(SUM(v.value/1024/1024),1) mbytes_sofar,
round(SUM(v.value /1024/1024)/nvl((SELECT MIN(elapsed_seconds)
FROM v$session_longops
WHERE OPNAME LIKE 'RMAN: aggregate input'
AND SOFAR != TOTALWORK
AND elapsed_seconds IS NOT NULL
),SUM(v.value /1024/1024)),2) mbytes_per_sec,
n.name
FROM gv$sesstat v,
v$statname n,
gv$session s
WHERE v.statistic#=n.statistic#
AND n.name = 'physical write total bytes'
AND v.sid = s.sid
AND v.inst_id=s.inst_id
AND s.program like 'rman@%'
GROUP BY 'DUPLICATE/RESTORE THROUGHPUT',n.name;
