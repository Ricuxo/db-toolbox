set pages 50
set lines 200
break on report

COLUMN "Tablespace" format a20
COLUMN "Total Size Mb"          FORMAT 999999.99
COLUMN "Used Mb"                FORMAT 999999.99
COLUMN "Free Mb"                FORMAT 999999.99
COLUMN "%Used"                  FORMAT 999999.99
COLUMN max_free                 FORMAT 999999.99 head "Max size |free chunk (Mb)"

compute sum of "Total Size Mb"  on report
compute sum of "Used Mb"        on report
compute sum of "Free Mb"        on report

SELECT a.tablespace_name 					"Tablespace", 
       TRUNC (a.total, 2) 					"Total Size Mb",
       TRUNC ((a.total - b.free), 2) 		"Used Mb", 
       TRUNC (b.free, 2) 					"Free Mb",
       100 - TRUNC ((b.free * 100) / a.total, 2) 	"%Used", 
       NVL (b.max_free, 0) 					max_free
  FROM (SELECT SUM (bytes)/1024/1024 total,
               tablespace_name
          FROM dba_data_files
         GROUP BY tablespace_name) a,
       (SELECT SUM (bytes)/1024/1024 	free,
               MAX (bytes)/1024/1024 	max_free, 
               tablespace_name
          FROM dba_free_space
         GROUP BY tablespace_name) b
 WHERE b.tablespace_name (+) = a.tablespace_name
UNION ALL
SELECT a.tablespace_name 				"Tablespace", 
       TRUNC (a.total, 2) 				"Total Size Mb",
       TRUNC (a.used, 2)  				"Used Mb", 
       TRUNC (b.free, 2) 				"Free Mb",
       100  - TRUNC ((b.free*100)/a.total,2)	"%Used",
       0								max_free
 FROM (SELECT SUM (bytes_used/1024/1024) 						used,
              SUM (bytes_used/1024/1024 + bytes_free/1024/1024) total,
              tablespace_name
         FROM v$temp_space_header
        GROUP BY tablespace_name) a,
      (SELECT SUM (bytes_free/1024/1024) free,
              tablespace_name
         FROM v$temp_space_header
        GROUP BY tablespace_name) b
   WHERE b.tablespace_name (+) = a.tablespace_name
ORDER BY 5 ;

