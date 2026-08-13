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


---Histórico de execuções e duração por etapa:

SELECT log_id,
       job_name,
       status,
       actual_start_date,
       run_duration,
       error#,
       additional_info
FROM   dba_scheduler_job_run_details
WHERE  job_name = 'JOB_CARGA_BI_POR_ETAPAS'
ORDER BY actual_start_date DESC
FETCH FIRST 20 ROWS ONLY;