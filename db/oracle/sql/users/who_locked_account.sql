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