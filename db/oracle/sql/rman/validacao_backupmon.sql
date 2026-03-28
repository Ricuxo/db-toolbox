set linesize 500 pagesize 2000
col Hours format 9999.99
col STATUS format a30
select SESSION_KEY, INPUT_TYPE, STATUS,
to_char(START_TIME,'dd-mm-yyyy hh24:mi:ss') as RMAN_Bkup_start_time,
to_char(END_TIME,'dd-mm-yyyy hh24:mi:ss') as RMAN_Bkup_end_time,
elapsed_seconds/3600 Hours from V$RMAN_BACKUP_JOB_DETAILS
order by session_key;


---EXECUTAR NO BANCO (verificar tempo de cada comando)
select  sid, row_type, operation, status, to_char(start_time,'dd-mm-yyyyhh24:mi:ss') start_time, to_char(end_time,'dd-mm-yyyy hh24:mi:ss')
end_time 
from
 v$rman_status
-- where operation='BACKUP';


---DO CATALOG

col TIME heading "TIME_SINCE_LAST_BACKUP(HOURS)" form 99999.99
col BACKUP_SIZE heading "BACKUP_SIZE(GB)"
col BACKUP_TYPE for a12
col DURATION heading "BACKUP|DURATION|(MIN)" form 99999.99
col TIME heading "TIME_SINCE|LAST_BACKUP|(HOURS)" form 99999.99
col BACKUP_SIZE heading "BACKUP_SIZE|(GB)"
 
SELECT A.DB_NAME
     ,A.OBJECT_TYPE "BACKUP_TYPE"
     ,TO_CHAR(A.START_TIME,'dd/mon/yyyy hh24:mi:ss') START_TIME
,TO_CHAR(A.END_TIME,'dd/mon/yyyy hh24:mi:ss') END_TIME
,ROUND((A.END_TIME-A.START_TIME)*24*60,2) DURATION
     ,ROUND((SYSDATE-A.END_TIME)*24,2) TIME
,ROUND(OUTPUT_BYTES/1024/1024/1024,2) BACKUP_SIZE
FROM rman.RC_RMAN_STATUS A,
     (SELECT DB_NAME,OBJECT_TYPE
     ,MAX(END_TIME) END_TIME
     FROM rman.RC_RMAN_STATUS
     WHERE
     OBJECT_TYPE IN ('DB FULL','DB INCR')
     AND
     STATUS like 'COMPLETED%'
     AND
     OPERATION in ('BACKUP','BACKUP COPYROLLFORWARD')
     GROUP BY DB_NAME,OBJECT_TYPE) B
WHERE A.OBJECT_TYPE IN ('DB FULL','DB INCR','ARCHIVELOG')
     AND
     STATUS like 'COMPLETED%'
     AND
     OPERATION in ('BACKUP','BACKUP COPYROLLFORWARD')
     AND
     A.DB_NAME=B.DB_NAME
     AND
     A.END_TIME=B.END_TIME
     AND A.OBJECT_TYPE=B.OBJECT_TYPE and
     A.end_time > sysdate- 1.5
ORDER BY 5 desc;


---NOS DATABASES

col STATUS format a9
col hrs format 999.99
select
SESSION_KEY, INPUT_TYPE, STATUS,
to_char(START_TIME,'mm/dd/yy hh24:mi') start_time,
to_char(END_TIME,'mm/dd/yy hh24:mi')   end_time,
elapsed_seconds/3600                   hrs
from V$RMAN_BACKUP_JOB_DETAILS
order by session_key;


-- Formatação...
SET PAGES 1000
SET LINES 210
COL STATUS FORMAT A30
COL HRS FORMAT 999.99

-- Backups Completos
SELECT
INPUT_TYPE, STATUS,
TO_CHAR(START_TIME,'DD/MM/YYYY HH24:MI') START_TIME,
TO_CHAR(END_TIME,'DD/MM/YYYY HH24:MI') END_TIME,
ELAPSED_SECONDS/3600 HRS
FROM V$RMAN_BACKUP_JOB_DETAILS
WHERE INPUT_TYPE='DB FULL'
ORDER BY SESSION_KEY;

-- Backups de Archived Redo Logs
SELECT
INPUT_TYPE, STATUS,
TO_CHAR(START_TIME,'DD/MM/YYYY HH24:MI') START_TIME,
TO_CHAR(END_TIME,'DD/MM/YYYY HH24:MI') END_TIME,
ELAPSED_SECONDS/3600 HRS
FROM V$RMAN_BACKUP_JOB_DETAILS
WHERE INPUT_TYPE='ARCHIVELOG'
ORDER BY SESSION_KEY;