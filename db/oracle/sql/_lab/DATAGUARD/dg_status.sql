SET PAGESIZE 124
COL DB_NAME FORMAT A8
COL HOSTNAME FORMAT A12
COL LOG_ARCHIVED FORMAT 999999
COL LOG_APPLIED FORMAT 999999
COL LOG_GAP FORMAT 9999
COL APPLIED_TIME FORMAT A12
SELECT db_name, hostname, log_archived, log_applied, applied_time,
       log_archived - log_applied log_gap
  FROM (SELECT NAME db_name
          FROM v$database),
       (SELECT UPPER (SUBSTR (host_name,
                              1,
                              (DECODE (INSTR (host_name, '.'),
                                       0, LENGTH (host_name),
                                       (INSTR (host_name, '.') - 1
                                       )
                                      )
                              )
                             )
                     ) hostname
          FROM v$instance),
       (SELECT MAX (sequence#) log_archived
          FROM v$archived_log
         WHERE dest_id = 1 AND archived = 'YES'),
       (SELECT MAX (sequence#) log_applied
          FROM v$archived_log
         WHERE dest_id = 2 AND applied = 'YES'),
       (SELECT TO_CHAR (MAX (completion_time), 'DD-MON/HH24:MI') applied_time
          FROM v$archived_log
         WHERE dest_id = 2 AND applied = 'YES');

SELECT 'Last Applied  : ' logs,
       TO_CHAR (next_time, 'DD-MON-YY HH24:MI:SS') TIME
  FROM gv$archived_log
 WHERE sequence# = (SELECT MAX (sequence#)
                      FROM v$archived_log
                     WHERE applied = 'YES')
UNION
SELECT 'Last Received : ' logs,
       TO_CHAR (next_time, 'DD-MON-YY HH24:MI:SS') TIME
  FROM gv$archived_log
 WHERE sequence# = (SELECT MAX (sequence#)
                      FROM v$archived_log);
