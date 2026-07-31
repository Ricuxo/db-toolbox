SELECT job_name,
       state,
       last_start_date,
       last_run_duration,
       next_run_date,
       run_count,
       failure_count,
       retry_count
FROM   dba_scheduler_jobs
WHERE  job_name = 'JOB_CARGA_BI_POR_ETAPAS';