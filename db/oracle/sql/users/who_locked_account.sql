-- Return code 1017 ( INVALID LOGIN ATTEMPT) 
-- Return code 28000 ( ACCOUNT LOCKED) 
set pagesize 1299 
set lines 299 
col username for a15 
col userhost for a13 
col timestamp for a39 
col terminal for a23 
SELECT username, userhost, terminal, timestamp, returncode
FROM dba_audit_session
WHERE username = '&USER_NAME'
AND returncode IN (1017, 28000)
AND timestamp >= SYSDATE - 7; ----ultima semana





SET LINESIZE 220 PAGESIZE 100
COL event_timestamp FOR A30
COL userhost        FOR A22
COL client_program  FOR A28
COL retorno         FOR A24

SELECT event_timestamp,
       userhost,
       client_program_name AS client_program,
       CASE return_code
            WHEN 0     THEN '0 - conectou'
            WHEN 1017  THEN '1017 - senha errada'
            WHEN 28000 THEN '28000 - conta travada'
            ELSE TO_CHAR(return_code)
       END AS retorno
FROM   unified_audit_trail
WHERE  action_name = 'LOGON'
AND    dbusername = UPPER('&usuario')
AND    event_timestamp > SYSTIMESTAMP - INTERVAL '2' DAY
ORDER  BY event_timestamp;