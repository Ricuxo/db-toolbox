exec DBMS_SCHEDULER.stop_JOB (job_name => 'REBUILD_IDX_BLEVEL_3',force=>true);


select 'exec DBMS_SCHEDULER.stop_JOB ('|| owner ||',''job_name => '|| job_name ||',force=>true);' from dba_jobs_running;