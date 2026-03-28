-- Consulta de JOB's...

set pagesize 150
SET line 250
col job            format 999999
col log_user       forma  a10
col job_definition format a80 word_wrap
col next_date      format a20
col username       format a15

SELECT job
,log_user
,TO_CHAR(next_date,'DD/MM/YYYY HH24:MI:SS')next_date
,ROUND((next_date - SYSDATE)*24*60) mins_to_exec
,what job_definition
,failures
,broken
FROM
dba_jobs
ORDER BY next_date ASC;
