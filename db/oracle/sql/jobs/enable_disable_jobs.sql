-- To check the job status:
col job_name for a30
select owner,JOB_NAME,JOB_ACTION,ENABLED,STATE from dba_scheduler_jobs ;

-- To Disable a job:
execute dbms_scheduler.disable('STATS_ADMMDC');

-- To enable a job:
execute dbms_scheduler.enable('owner.job');