SELECT owner_name, job_name, operation, job_mode,
state, attached_sessions
FROM dba_datapump_jobs
WHERE job_name NOT LIKE 'BIN$%'
ORDER BY 1,2;