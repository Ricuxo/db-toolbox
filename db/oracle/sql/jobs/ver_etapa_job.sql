-- DBMS_SCHEDULER
SELECT job_name,
       job_type,
       job_action,       -- procedure/bloco PL/SQL que executa
       state,
       last_start_date,
       last_run_duration,
       next_run_date
FROM   dba_scheduler_jobs
WHERE  job_name = 'JOB_CARGA_BI_POR_ETAPAS';

-- DBMS_JOB (legado)
SELECT job,
       what,             -- código PL/SQL que executa
       last_date,
       next_date,
       broken,
       failures
FROM   dba_jobs
WHERE  what LIKE '%CARGA_BI%';