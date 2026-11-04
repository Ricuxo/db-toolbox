-- =============================================================================
-- check_auditoria.sql
-- Diagnostico de auditoria e housekeeping (Unified + Tradicional) - Oracle 12.2+
--
-- SOMENTE LEITURA: nenhum comando altera o banco.
-- Execucao : sqlplus / as sysdba @check_auditoria.sql
-- RAC      : rodar em apenas um no.
-- CDB      : rodar em cada PDB (ALTER SESSION SET CONTAINER = <pdb>).
-- Saida    : check_auditoria_<DB>_<data>.log no diretorio corrente.
-- =============================================================================

SET LINESIZE 250 PAGESIZE 200 FEEDBACK OFF VERIFY OFF TRIMSPOOL ON TAB OFF
SET LONG 4000

COLUMN spool_name NEW_VALUE v_spool NOPRINT
SELECT 'check_auditoria_' || name || '_' || TO_CHAR(SYSDATE, 'YYYYMMDD_HH24MI') || '.log' AS spool_name
FROM   v$database;
SPOOL &v_spool

PROMPT
PROMPT =============================================================================
PROMPT  0. IDENTIFICACAO DO AMBIENTE
PROMPT =============================================================================
COLUMN name            FORMAT A12
COLUMN db_unique_name  FORMAT A15
COLUMN database_role   FORMAT A16
COLUMN host_name       FORMAT A30
COLUMN version         FORMAT A12
COLUMN unified_puro    FORMAT A12
COLUMN audit_trail     FORMAT A15
COLUMN audit_sys_ops   FORMAT A13
COLUMN cdb             FORMAT A4
SELECT d.name,
       d.db_unique_name,
       d.database_role,
       i.host_name,
       i.version,
       (SELECT value FROM v$option    WHERE parameter = 'Unified Auditing')     AS unified_puro,
       (SELECT value FROM v$parameter WHERE name = 'audit_trail')               AS audit_trail,
       (SELECT value FROM v$parameter WHERE name = 'audit_sys_operations')      AS audit_sys_ops,
       d.cdb
FROM   v$database d, v$instance i;

PROMPT
PROMPT =============================================================================
PROMPT  1. RESUMO DE ACHADOS
PROMPT =============================================================================
COLUMN ordem       NOPRINT
COLUMN verificacao FORMAT A45
COLUMN status      FORMAT A12
COLUMN detalhe     FORMAT A120 WORD_WRAPPED

-- Corte (last archive timestamp) do UNIFIED
SELECT 10 AS ordem,
       'Corte UNIFIED definido e recente'                                AS verificacao,
       CASE WHEN COUNT(*) = 0 THEN 'ALERTA'
            WHEN MAX(last_archive_ts) < SYSTIMESTAMP - INTERVAL '120' DAY THEN 'ALERTA'
            ELSE 'OK' END                                                AS status,
       NVL(TO_CHAR(MAX(last_archive_ts), 'YYYY-MM-DD HH24:MI:SS TZR'),
           'nao definido - purge do UNIFIED nunca apaga nada')           AS detalhe
FROM   dba_audit_mgmt_last_arch_ts
WHERE  audit_trail = 'UNIFIED AUDIT TRAIL'
UNION ALL
-- Corte do STANDARD
SELECT 11,
       'Corte STANDARD definido e recente',
       CASE WHEN COUNT(*) = 0 THEN 'ALERTA'
            WHEN MAX(last_archive_ts) < SYSTIMESTAMP - INTERVAL '120' DAY THEN 'ALERTA'
            ELSE 'OK' END,
       NVL(TO_CHAR(MAX(last_archive_ts), 'YYYY-MM-DD HH24:MI:SS TZR'), 'nao definido')
FROM   dba_audit_mgmt_last_arch_ts
WHERE  audit_trail = 'STANDARD AUDIT TRAIL'
UNION ALL
-- Job de purge cobrindo o UNIFIED
SELECT 20,
       'Job de purge do UNIFIED ativo',
       CASE WHEN COUNT(*) = 0 THEN 'ALERTA' ELSE 'OK' END,
       COUNT(*) || ' job(s) ENABLED no DBMS_AUDIT_MGMT'
FROM   dba_audit_mgmt_cleanup_jobs
WHERE  job_status = 'ENABLED'
AND   (audit_trail LIKE '%UNIFIED%' OR audit_trail LIKE 'ALL%')
UNION ALL
-- Job de purge cobrindo STD/FGA
SELECT 21,
       'Job de purge do STANDARD/FGA ativo',
       CASE WHEN COUNT(*) = 0 THEN 'ALERTA' ELSE 'OK' END,
       COUNT(*) || ' job(s) ENABLED no DBMS_AUDIT_MGMT'
FROM   dba_audit_mgmt_cleanup_jobs
WHERE  job_status = 'ENABLED'
AND   (audit_trail LIKE '%STANDARD%' OR audit_trail LIKE 'ALL%')
UNION ALL
-- Metadado do DBMS_AUDIT_MGMT x scheduler (caso do job sobrescrito manualmente)
SELECT 22,
       'Metadado de purge consistente c/ scheduler',
       CASE WHEN COUNT(*) = 0 THEN 'OK' ELSE 'ALERTA' END,
       NVL(LISTAGG(c.job_name || ' (metadado=' || c.job_status || ')', ', ')
             WITHIN GROUP (ORDER BY c.job_name),
           'metadado e scheduler batem')
FROM   dba_audit_mgmt_cleanup_jobs c
WHERE  NOT EXISTS (
         SELECT 1
         FROM   dba_scheduler_jobs s
         WHERE  s.job_name = c.job_name
         AND    s.owner IN ('AUDSYS', 'SYS')
         AND  ((c.job_status = 'ENABLED'  AND s.enabled = 'TRUE')
            OR (c.job_status = 'DISABLED' AND s.enabled = 'FALSE')))
UNION ALL
-- Politicas ORA_* de baseline
SELECT 30,
       'Politica ' || p.pol,
       CASE WHEN e.policy_name IS NOT NULL THEN 'OK'
            WHEN p.obrig = 'S' THEN 'ALERTA'
            ELSE 'RECOMENDADO' END,
       CASE WHEN e.policy_name IS NOT NULL THEN 'habilitada'
            WHEN p.obrig = 'S' THEN 'desabilitada - padrao Oracle em bancos novos (perdida em upgrade?)'
            ELSE 'desabilitada - boa pratica adicional (STIG)' END
FROM  (SELECT 'ORA_SECURECONFIG'       AS pol, 'S' AS obrig FROM dual UNION ALL
       SELECT 'ORA_LOGON_FAILURES',            'S'          FROM dual UNION ALL
       SELECT 'ORA_ACCOUNT_MGMT',              'N'          FROM dual UNION ALL
       SELECT 'ORA_DATABASE_PARAMETER',        'N'          FROM dual) p
LEFT JOIN (SELECT DISTINCT policy_name FROM audit_unified_enabled_policies) e
       ON e.policy_name = p.pol
UNION ALL
-- ORA_LOGON_FAILURES deve auditar so falhas
SELECT 31,
       'ORA_LOGON_FAILURES somente falhas',
       CASE WHEN COUNT(*) = 0 THEN 'N/A'
            WHEN MAX(success) = 'YES' THEN 'ALERTA'
            ELSE 'OK' END,
       CASE WHEN COUNT(*) = 0 THEN 'politica nao habilitada'
            WHEN MAX(success) = 'YES' THEN 'audita logons com sucesso - volume alto com connection pool'
            ELSE 'WHENEVER NOT SUCCESSFUL' END
FROM   audit_unified_enabled_policies
WHERE  policy_name = 'ORA_LOGON_FAILURES'
UNION ALL
-- Politicas ACTIONS ALL (sem objeto) habilitadas
SELECT 40,
       'Politicas ACTIONS ALL habilitadas',
       CASE WHEN COUNT(*) = 0 THEN 'OK' ELSE 'ATENCAO' END,
       NVL(LISTAGG(e.policy_name || ' BY ' || e.entity_name, ', ' ON OVERFLOW TRUNCATE)
             WITHIN GROUP (ORDER BY e.policy_name),
           'nenhuma')
FROM   audit_unified_enabled_policies e
WHERE  EXISTS (SELECT 1
               FROM   audit_unified_policies p
               WHERE  p.policy_name       = e.policy_name
               AND    p.audit_option      = 'ALL'
               AND    p.audit_option_type = 'STANDARD ACTION'
               AND    p.object_name       = 'NONE')
UNION ALL
-- Trilhas gravando em SYSAUX
SELECT 50,
       'Trilha de auditoria fora da SYSAUX',
       CASE WHEN COUNT(*) = 0 THEN 'OK' ELSE 'ALERTA' END,
       NVL(LISTAGG(audit_trail, ', ') WITHIN GROUP (ORDER BY audit_trail),
           'nenhuma trilha na SYSAUX')
FROM   dba_audit_mgmt_config_params
WHERE  parameter_name  = 'DB AUDIT TABLESPACE'
AND    parameter_value = 'SYSAUX'
UNION ALL
-- Tamanho do AUD$
SELECT 51,
       'Tamanho SYS.AUD$ (MB)',
       CASE WHEN NVL(SUM(bytes), 0) > 10 * POWER(1024, 3) THEN 'ATENCAO' ELSE 'OK' END,
       TO_CHAR(ROUND(NVL(SUM(bytes), 0) / 1024 / 1024))
FROM   dba_segments
WHERE  owner = 'SYS' AND segment_name = 'AUD$'
UNION ALL
-- Tamanho total do schema AUDSYS
SELECT 52,
       'Tamanho AUDSYS (UNIFIED) (MB)',
       CASE WHEN NVL(SUM(bytes), 0) > 50 * POWER(1024, 3) THEN 'ATENCAO' ELSE 'OK' END,
       TO_CHAR(ROUND(NVL(SUM(bytes), 0) / 1024 / 1024))
FROM   dba_segments
WHERE  owner = 'AUDSYS'
UNION ALL
-- Intervalo de particao do AUD$UNIFIED
SELECT 53,
       'Intervalo de particao do AUD$UNIFIED',
       CASE WHEN MAX(interval) LIKE '%DAY%' THEN 'OK' ELSE 'RECOMENDADO' END,
       NVL(MAX(interval), 'tabela nao particionada / nao encontrada')
FROM   dba_part_tables
WHERE  owner = 'AUDSYS' AND table_name = 'AUD$UNIFIED'
ORDER  BY 1;

PROMPT
PROMPT =============================================================================
PROMPT  2. POLITICAS UNIFICADAS HABILITADAS
PROMPT =============================================================================
COLUMN policy_name    FORMAT A35
COLUMN enabled_option FORMAT A15
COLUMN entity_name    FORMAT A30
COLUMN success        FORMAT A7
COLUMN failure        FORMAT A7
SELECT policy_name, enabled_option, entity_name, success, failure
FROM   audit_unified_enabled_policies
ORDER  BY policy_name, entity_name;

PROMPT
PROMPT =============================================================================
PROMPT  3. POLITICAS CRIADAS E NAO HABILITADAS
PROMPT =============================================================================
COLUMN qtd_itens FORMAT 9999
SELECT p.policy_name, COUNT(*) AS qtd_itens
FROM   audit_unified_policies p
WHERE  NOT EXISTS (SELECT 1 FROM audit_unified_enabled_policies e
                   WHERE e.policy_name = p.policy_name)
GROUP  BY p.policy_name
ORDER  BY p.policy_name;

PROMPT
PROMPT =============================================================================
PROMPT  4. CONFIGURACAO DO DBMS_AUDIT_MGMT
PROMPT =============================================================================
COLUMN parameter_name  FORMAT A30
COLUMN parameter_value FORMAT A25
COLUMN audit_trail     FORMAT A30
SELECT parameter_name, parameter_value, audit_trail
FROM   dba_audit_mgmt_config_params
ORDER  BY audit_trail, parameter_name;

PROMPT
PROMPT =============================================================================
PROMPT  5. CORTES (LAST ARCHIVE TIMESTAMP)
PROMPT  Linhas antigas (ex: anos atras) podem ser de outro DATABASE_ID - verificar.
PROMPT =============================================================================
COLUMN audit_trail     FORMAT A25
COLUMN rac_instance    FORMAT 999
COLUMN last_archive_ts FORMAT A40
COLUMN database_id     FORMAT 99999999999
SELECT audit_trail, rac_instance, database_id,
       TO_CHAR(last_archive_ts, 'YYYY-MM-DD HH24:MI:SS TZR') AS last_archive_ts
FROM   dba_audit_mgmt_last_arch_ts
ORDER  BY audit_trail, last_archive_ts;

PROMPT
PROMPT =============================================================================
PROMPT  6. JOBS DE PURGE (METADADO) x SCHEDULER
PROMPT =============================================================================
COLUMN job_name      FORMAT A30
COLUMN job_status    FORMAT A10
COLUMN job_frequency FORMAT A30
SELECT job_name, job_status, audit_trail, job_frequency
FROM   dba_audit_mgmt_cleanup_jobs
ORDER  BY job_name;

COLUMN owner         FORMAT A12
COLUMN enabled       FORMAT A7
COLUMN state         FORMAT A10
COLUMN repeat_interval FORMAT A35
COLUMN next_run_date FORMAT A30
COLUMN last_start    FORMAT A30
COLUMN job_action    FORMAT A60 WORD_WRAPPED
SELECT owner, job_name, enabled, state, repeat_interval,
       TO_CHAR(last_start_date, 'YYYY-MM-DD HH24:MI TZR') AS last_start,
       TO_CHAR(next_run_date,  'YYYY-MM-DD HH24:MI TZR') AS next_run_date,
       SUBSTR(job_action, 1, 200)                        AS job_action
FROM   dba_scheduler_jobs
WHERE  job_name IN (SELECT job_name FROM dba_audit_mgmt_cleanup_jobs)
   OR  UPPER(job_action) LIKE '%AUDIT_MGMT%'
   OR  UPPER(job_action) LIKE '%ARCHIVE_TIMESTAMP%'
   OR  UPPER(job_name)   LIKE '%AUDIT%'
ORDER  BY owner, job_name;

PROMPT
PROMPT =============================================================================
PROMPT  7. ULTIMAS EXECUCOES DOS JOBS DE PURGE
PROMPT =============================================================================
COLUMN status       FORMAT A12
COLUMN actual_start FORMAT A30
COLUMN run_duration FORMAT A20
COLUMN error#       FORMAT 999999
SELECT owner, job_name, status,
       TO_CHAR(actual_start_date, 'YYYY-MM-DD HH24:MI TZR') AS actual_start,
       TO_CHAR(run_duration)                                 AS run_duration,
       error#
FROM   dba_scheduler_job_run_details
WHERE  job_name IN (SELECT job_name FROM dba_audit_mgmt_cleanup_jobs)
ORDER  BY actual_start_date DESC
FETCH FIRST 10 ROWS ONLY;

PROMPT
PROMPT =============================================================================
PROMPT  8. ROTINAS CUSTOMIZADAS QUE DEFINEM O CORTE
PROMPT  Verifique se AUDIT_TRAIL_UNIFIED aparece e se a linha esta comentada (--).
PROMPT =============================================================================
COLUMN name FORMAT A30
COLUMN line FORMAT 99999
COLUMN text FORMAT A110 WORD_WRAPPED
SELECT s.owner, s.name, s.line, TRIM(REPLACE(s.text, CHR(10))) AS text
FROM   dba_source s
WHERE  (s.owner, s.name) IN (
         SELECT DISTINCT owner, name
         FROM   dba_source
         WHERE  UPPER(text) LIKE '%SET_LAST_ARCHIVE_TIMESTAMP%'
         AND    name NOT LIKE 'DBMS_AUDIT_MGMT%'
         AND    owner NOT IN ('AUDSYS'))
AND    UPPER(s.text) LIKE '%AUDIT_TRAIL_%'
ORDER  BY s.owner, s.name, s.line;

PROMPT
PROMPT =============================================================================
PROMPT  9. PARTICOES DO AUD$UNIFIED
PROMPT =============================================================================
COLUMN partition_name FORMAT A20
COLUMN high_value     FORMAT A40
COLUMN mb             FORMAT 999,999,999
SELECT p.partition_position,
       p.partition_name,
       p.high_value,
       ROUND(s.bytes / 1024 / 1024) AS mb
FROM   dba_tab_partitions p
LEFT JOIN dba_segments s
       ON  s.owner          = p.table_owner
       AND s.segment_name   = p.table_name
       AND s.partition_name = p.partition_name
WHERE  p.table_owner = 'AUDSYS'
AND    p.table_name  = 'AUD$UNIFIED'
ORDER  BY p.partition_position;

PROMPT
PROMPT =============================================================================
PROMPT  10. SEGMENTOS DE AUDITORIA E TABLESPACES
PROMPT =============================================================================
COLUMN segment_name    FORMAT A30
COLUMN tablespace_name FORMAT A20
SELECT owner, segment_name, tablespace_name, ROUND(SUM(bytes) / 1024 / 1024) AS mb
FROM   dba_segments
WHERE  (owner = 'SYS' AND segment_name IN ('AUD$', 'FGA_LOG$'))
   OR   owner = 'AUDSYS'
GROUP  BY owner, segment_name, tablespace_name
ORDER  BY mb DESC;

COLUMN alocado_gb  FORMAT 999,999.9
COLUMN livre_gb    FORMAT 999,999.9
COLUMN max_gb      FORMAT 999,999.9
SELECT df.tablespace_name,
       ROUND(SUM(df.bytes) / POWER(1024, 3), 1)                                         AS alocado_gb,
       ROUND((SELECT NVL(SUM(fs.bytes), 0) FROM dba_free_space fs
              WHERE fs.tablespace_name = df.tablespace_name) / POWER(1024, 3), 1)      AS livre_gb,
       ROUND(SUM(DECODE(df.autoextensible, 'YES', df.maxbytes, df.bytes)) / POWER(1024, 3), 1) AS max_gb
FROM   dba_data_files df
WHERE  df.tablespace_name IN (SELECT DISTINCT parameter_value
                              FROM   dba_audit_mgmt_config_params
                              WHERE  parameter_name = 'DB AUDIT TABLESPACE')
GROUP  BY df.tablespace_name
ORDER  BY df.tablespace_name;

PROMPT
PROMPT =============================================================================
PROMPT  11. OPCOES DE AUDITORIA TRADICIONAL ATIVAS (origem do volume no AUD$)
PROMPT =============================================================================
COLUMN tipo FORMAT A20
SELECT 'STATEMENT' AS tipo, COUNT(*) AS qtd FROM dba_stmt_audit_opts
UNION ALL
SELECT 'PRIVILEGE',         COUNT(*)        FROM dba_priv_audit_opts
UNION ALL
SELECT 'OBJECT',            COUNT(*)        FROM dba_obj_audit_opts;

COLUMN user_name   FORMAT A20
COLUMN audit_option FORMAT A35
SELECT NVL(user_name, '(todos)') AS user_name, audit_option, success, failure
FROM   dba_stmt_audit_opts
ORDER  BY audit_option, user_name;

PROMPT
PROMPT =============================================================================
PROMPT  12. (OPCIONAL - PESADO) DISTRIBUICAO MENSAL DO AUD$
PROMPT  Faz full scan do AUD$. Descomente e rode fora do horario de pico.
PROMPT =============================================================================
-- SELECT TRUNC(CAST(ntimestamp# AS DATE), 'MM') AS mes, COUNT(*) AS registros
-- FROM   sys.aud$
-- GROUP  BY TRUNC(CAST(ntimestamp# AS DATE), 'MM')
-- ORDER  BY 1;

PROMPT
PROMPT Fim do diagnostico. Arquivo gerado: &v_spool
SPOOL OFF
SET FEEDBACK ON VERIFY ON
