SET LINESIZE 300 PAGESIZE 120
COL dbusername             FOR A14
COL pod                    FOR A26
COL ultima_conexao_ok_conta FOR A34
COL primeira_errada        FOR A30
COL ultima_errada          FOR A30
COL primeiro_bloqueio      FOR A30
COL ultimo_bloqueio        FOR A30

SELECT uat.dbusername,
       REGEXP_REPLACE(uat.userhost, '-[a-z0-9]{8,10}-[a-z0-9]{5}$', '') AS pod,
       (SELECT du.last_login
          FROM dba_users du
         WHERE du.username = uat.dbusername)                           AS ultima_conexao_ok_conta,
       CAST(MIN(CASE WHEN uat.return_code = 1017  THEN uat.event_timestamp END)
            AT TIME ZONE 'America/Sao_Paulo' AS TIMESTAMP)             AS primeira_errada,
       CAST(MAX(CASE WHEN uat.return_code = 1017  THEN uat.event_timestamp END)
            AT TIME ZONE 'America/Sao_Paulo' AS TIMESTAMP)             AS ultima_errada,
       CAST(MIN(CASE WHEN uat.return_code = 28000 THEN uat.event_timestamp END)
            AT TIME ZONE 'America/Sao_Paulo' AS TIMESTAMP)             AS primeiro_bloqueio,
       CAST(MAX(CASE WHEN uat.return_code = 28000 THEN uat.event_timestamp END)
            AT TIME ZONE 'America/Sao_Paulo' AS TIMESTAMP)             AS ultimo_bloqueio,
       COUNT(CASE WHEN uat.return_code = 1017  THEN 1 END)             AS qtd_erradas,
       COUNT(CASE WHEN uat.return_code = 28000 THEN 1 END)             AS qtd_bloqueio
FROM   unified_audit_trail uat
WHERE  uat.action_name = 'LOGON'
AND    uat.return_code IN (1017, 28000)
AND    uat.event_timestamp > SYSTIMESTAMP - INTERVAL '2' DAY
GROUP  BY uat.dbusername,
         REGEXP_REPLACE(uat.userhost, '-[a-z0-9]{8,10}-[a-z0-9]{5}$', '')
ORDER  BY primeira_errada NULLS LAST;


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



SELECT userhost,
       client_program_name AS client_program,
       COUNT(CASE WHEN return_code = 0    THEN 1 END) AS sucesso,
       COUNT(CASE WHEN return_code = 1017 THEN 1 END) AS senha_errada,
       COUNT(CASE WHEN return_code = 28000 THEN 1 END) AS conta_travada,
       MAX(event_timestamp) AS ultimo_evento
FROM   unified_audit_trail
WHERE  action_name = 'LOGON'
AND    dbusername = UPPER('PIX')
AND    event_timestamp > SYSTIMESTAMP - INTERVAL '2' DAY
GROUP  BY userhost, client_program_name
ORDER  BY senha_errada DESC;