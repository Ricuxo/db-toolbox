SET LINESIZE 300 VERIFY OFF

COLUMN log_date FORMAT A35
COLUMN owner FORMAT A20
COLUMN job_name FORMAT A30
COLUMN errors FORMAT A20
COLUMN req_start_date FORMAT A35
COLUMN actual_start_date FORMAT A35
COLUMN run_duration FORMAT A20
COLUMN additional_info FORMAT A30
COLUMN status format a10

SELECT log_date,
       owner,
       job_name,
       status,
       errors,
       req_start_date,
       actual_start_date,
       run_duration,
       additional_info
FROM   dba_scheduler_job_run_details
WHERE  
--STATUS = 'FAILED'
ORDER BY log_date;