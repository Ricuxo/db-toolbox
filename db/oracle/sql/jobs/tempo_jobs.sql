SELECT log_id, job_name, status, 
       actual_start_date,
       run_duration,
       error#
FROM dba_scheduler_job_run_details
WHERE job_name = 'JOB_INTEGRACAO_REMESSA_ONLINE'
ORDER BY actual_start_date DESC
FETCH FIRST 10 ROWS ONLY;