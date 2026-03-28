---------------------------------------------------------------------------------------------------------------------------------------------
-- VERIFICA ESPAÇO LIVRE NECESSÁRIO PARA CADA TABLESPACE - TABLES
---------------------------------------------------------------------------------------------------------------------------------------------

compute sum of DATA_128K ON report
compute sum of DATA_4M ON report
compute sum of DATA_128M ON report
compute sum of "VERY LARGE" ON report
break on report

SELECT a.owner, 
       ROUND(NVL(SUM(a.M128),0),2) AS "DATA_128K",
       ROUND(NVL(SUM(a.G4),0),2) AS "DATA_4M",
       ROUND(NVL(SUM(a.G128),0),2) AS "DATA_128M",
       ROUND(NVL(SUM(a.BIG),0),2) AS "VERY LARGE"
FROM(
SELECT 
       owner,
       CASE WHEN (BYTES/1024/1024) <= 128 THEN (BYTES/1024/1024) ELSE 0 END AS M128, 
       CASE WHEN (BYTES/1024/1024) > 128  AND (BYTES/1024/1024) <= 4096 THEN (BYTES/1024/1024) ELSE 0 END AS G4,
       CASE WHEN (BYTES/1024/1024) > 4096 AND (BYTES/1024/1024) <= 131072 THEN (BYTES/1024/1024) ELSE 0 END AS G128,
       CASE WHEN (BYTES/1024/1024) > 131072 THEN 1 ELSE 0 END AS BIG
FROM dba_segments
WHERE segment_name NOT LIKE 'BIN$%'--Desconsiderando as tabelas da lixeira.
  AND segment_type IN ('TABLE','TABLE PARTITION','NESTED TABLE','LOBSEGMENT','LOBINDEX')
  AND OWNER NOT IN ('DSF','DSFCEM','POS','RTG','SYS','SYSTEM','CTAS_CHANGE_BACKUP','WMSYS','PERFSTAT')) A
GROUP BY a.owner
ORDER BY 1;

---------------------------------------------------------------------------------------------------------------------------------------------
-- VERIFICA ESPAÇO LIVRE NECESSÁRIO PARA CADA TABLESPACE - INDEXES
---------------------------------------------------------------------------------------------------------------------------------------------

compute sum of INDX_128K ON report
compute sum of INDX_4M ON report
compute sum of INDX_128M ON report
compute sum of "VERY LARGE" ON report
break on report

SELECT a.owner, 
       ROUND(NVL(SUM(a.M128),0),2) AS "INDX_128K",
       ROUND(NVL(SUM(a.G4),0),2) AS "INDX_4M",
       ROUND(NVL(SUM(a.G128),0),2) AS "INDX_128M",
       ROUND(NVL(SUM(a.BIG),0),2) AS "VERY LARGE"
FROM(
SELECT 
       owner,
       CASE WHEN (BYTES/1024/1024) <= 128 THEN (BYTES/1024/1024) ELSE 0 END AS M128, 
       CASE WHEN (BYTES/1024/1024) > 128  AND (BYTES/1024/1024) <= 4096 THEN (BYTES/1024/1024) ELSE 0 END AS G4,
       CASE WHEN (BYTES/1024/1024) > 4096 AND (BYTES/1024/1024) <= 131072 THEN (BYTES/1024/1024) ELSE 0 END AS G128,
       CASE WHEN (BYTES/1024/1024) > 131072 THEN 1 ELSE 0 END AS BIG
FROM dba_segments
WHERE segment_name NOT LIKE 'BIN$%'--Desconsiderando as tabelas da lixeira.
  AND segment_type IN ('INDEX','INDEX PARTITION')
  AND OWNER NOT IN ('DSF','DSFCEM','POS','RTG','SYS','SYSTEM','CTAS_CHANGE_BACKUP','WMSYS','PERFSTAT')) A
GROUP BY a.owner
ORDER BY 1;
