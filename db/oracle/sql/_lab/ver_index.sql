
SELECT owner, tablespace_name, SUM(BYTES)/1024/1024 as Size_MB 
  FROM dba_segments 
 WHERE segment_type='INDEX' 
   AND owner NOT IN ('SYS','SYSTEM','SYSMAN')
 GROUP BY owner, TABLESPACE_NAME
 ORDER BY 3
/

