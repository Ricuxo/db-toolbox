-- =============================================================================
-- SCRIPT: inventory_oracle.sql
-- DESCRICAO: Coleta completa de inventario e diagnostico do ambiente Oracle
-- COMPATIBILIDADE: Oracle 11g, 12c, 18c, 19c | Standalone, RAC, CDB/PDB
-- EXECUCAO: sqlplus / as sysdba @inventory_oracle.sql
-- SAIDA: inventory_oracle_YYYYMMDD_HH24MI.log
-- =============================================================================

-- Configuracao do spool
DEFINE arquivo = 'inventory_oracle_'
COLUMN dt_arquivo NEW_VALUE dt_arquivo NOPRINT
SELECT TO_CHAR(SYSDATE,'YYYYMMDD_HH24MI') dt_arquivo FROM dual;

SPOOL &arquivo.&dt_arquivo..log

-- Configuracao de formatacao
SET LINESIZE    220
SET PAGESIZE    100
SET TRIMSPOOL   ON
SET TRIMOUT     ON
SET FEEDBACK    OFF
SET VERIFY      OFF
SET HEADING     ON
SET ECHO        OFF
SET WRAP        OFF
SET LONG        50000
SET SERVEROUTPUT ON SIZE UNLIMITED

-- =============================================================================
-- CABECALHO
-- =============================================================================
PROMPT
PROMPT ================================================================================
PROMPT  INVENTARIO E DIAGNOSTICO DO AMBIENTE ORACLE
PROMPT  Data/Hora : &&dt_arquivo
PROMPT ================================================================================
PROMPT

-- =============================================================================
-- BLOCO 1 — IDENTIFICACAO DO BANCO
-- =============================================================================
PROMPT ================================================================================
PROMPT  [1] IDENTIFICACAO DO BANCO
PROMPT ================================================================================
PROMPT

PROMPT --- [1.1] Versao Oracle ---
SELECT banner FROM v$version;

PROMPT
PROMPT --- [1.2] Identidade e modo do banco ---
COLUMN name              FORMAT A20  HEADING 'DB Name'
COLUMN db_unique_name    FORMAT A25  HEADING 'DB Unique Name'
COLUMN open_mode         FORMAT A20  HEADING 'Open Mode'
COLUMN log_mode          FORMAT A15  HEADING 'Log Mode'
COLUMN cdb               FORMAT A5   HEADING 'CDB?'
COLUMN platform_name     FORMAT A35  HEADING 'Plataforma'
COLUMN created           FORMAT A12  HEADING 'Criado Em'

SELECT name,
       db_unique_name,
       open_mode,
       log_mode,
       cdb,
       platform_name,
       TO_CHAR(created,'DD/MM/YYYY') created
FROM v$database;

PROMPT
PROMPT --- [1.3] Instancias (RAC) ---
COLUMN inst_id        FORMAT 999    HEADING 'Inst'
COLUMN instance_name  FORMAT A20    HEADING 'Instance Name'
COLUMN host_name      FORMAT A30    HEADING 'Host'
COLUMN version        FORMAT A15    HEADING 'Versao'
COLUMN status         FORMAT A15    HEADING 'Status'
COLUMN startup_time   FORMAT A20    HEADING 'Startup'

SELECT inst_id,
       instance_name,
       host_name,
       version,
       status,
       TO_CHAR(startup_time,'DD/MM/YYYY HH24:MI') startup_time
FROM gv$instance
ORDER BY inst_id;

PROMPT
PROMPT --- [1.4] PDBs (somente CDB) ---
COLUMN con_id       FORMAT 999    HEADING 'Con ID'
COLUMN pdb_name     FORMAT A25    HEADING 'PDB Name'
COLUMN open_mode    FORMAT A15    HEADING 'Open Mode'
COLUMN restricted   FORMAT A10    HEADING 'Restricted'
COLUMN pdb_created  FORMAT A12    HEADING 'Criado Em'

SELECT con_id,
       name          pdb_name,
       open_mode,
       restricted,
       TO_CHAR(creation_time,'DD/MM/YYYY') pdb_created
FROM v$pdbs
ORDER BY con_id;

-- =============================================================================
-- BLOCO 2 — PARAMETROS CRITICOS
-- =============================================================================
PROMPT
PROMPT ================================================================================
PROMPT  [2] PARAMETROS CRITICOS
PROMPT ================================================================================
PROMPT

COLUMN param_name   FORMAT A45    HEADING 'Parametro'
COLUMN param_value  FORMAT A60    HEADING 'Valor'

SELECT name  param_name,
       value param_value
FROM v$parameter
WHERE name IN (
  'db_name','db_unique_name','db_domain',
  'sga_target','sga_max_size',
  'pga_aggregate_target','pga_aggregate_limit',
  'memory_target','memory_max_target',
  'db_cache_size','shared_pool_size',
  'processes','sessions',
  'log_buffer',
  'log_archive_dest_1','log_archive_dest_2','log_archive_format',
  'db_block_size','db_files',
  'undo_tablespace','undo_retention',
  'parallel_max_servers','parallel_degree_policy',
  'optimizer_features_enable',
  'control_management_pack_access',
  'enable_ddl_logging','audit_trail',
  'remote_listener','local_listener',
  'cluster_database','cluster_database_instances',
  'archive_lag_target','db_recovery_file_dest',
  'db_recovery_file_dest_size'
)
ORDER BY name;

-- =============================================================================
-- BLOCO 3 — ESPACO E STORAGE
-- =============================================================================
PROMPT
PROMPT ================================================================================
PROMPT  [3] ESPACO E STORAGE
PROMPT ================================================================================
PROMPT

PROMPT --- [3.1] Uso de Tablespaces ---
COLUMN tablespace_name   FORMAT A30   HEADING 'Tablespace'
COLUMN contents          FORMAT A12   HEADING 'Tipo'
COLUMN ext_mgmt          FORMAT A10   HEADING 'Ext Mgmt'
COLUMN seg_mgmt          FORMAT A10   HEADING 'Seg Mgmt'
COLUMN total_mb          FORMAT 999,999,990.99  HEADING 'Total MB'
COLUMN used_mb           FORMAT 999,999,990.99  HEADING 'Usado MB'
COLUMN free_mb           FORMAT 999,999,990.99  HEADING 'Livre MB'
COLUMN pct_used          FORMAT 990.99  HEADING '% Usado'
COLUMN autoextend        FORMAT A10   HEADING 'Autoext'

SELECT df.tablespace_name,
       dt.contents,
       dt.extent_management          ext_mgmt,
       dt.segment_space_management   seg_mgmt,
       ROUND(df.total_mb,2)                                    total_mb,
       ROUND(df.total_mb - NVL(fs.free_mb,0),2)               used_mb,
       ROUND(NVL(fs.free_mb,0),2)                             free_mb,
       ROUND((df.total_mb - NVL(fs.free_mb,0))
             / NULLIF(df.total_mb,0) * 100, 2)                pct_used,
       df.autoextend
FROM (
  SELECT tablespace_name,
         SUM(bytes)/1024/1024                                  total_mb,
         MAX(DECODE(autoextensible,'YES','SIM','NAO'))         autoextend
  FROM dba_data_files
  GROUP BY tablespace_name
) df
JOIN dba_tablespaces dt
  ON df.tablespace_name = dt.tablespace_name
LEFT JOIN (
  SELECT tablespace_name, SUM(bytes)/1024/1024 free_mb
  FROM dba_free_space
  GROUP BY tablespace_name
) fs ON df.tablespace_name = fs.tablespace_name
ORDER BY pct_used DESC NULLS LAST;

PROMPT
PROMPT --- [3.2] Tablespace TEMP ---
COLUMN tablespace_name   FORMAT A30   HEADING 'Tablespace'
COLUMN total_mb          FORMAT 999,999,990.99  HEADING 'Total MB'
COLUMN free_mb           FORMAT 999,999,990.99  HEADING 'Livre MB'
COLUMN pct_used          FORMAT 990.99  HEADING '% Usado'

SELECT tablespace_name,
       ROUND(tablespace_size /1024/1024,2) total_mb,
       ROUND(free_space      /1024/1024,2) free_mb,
       ROUND((tablespace_size - free_space)
             / NULLIF(tablespace_size,0)*100,2) pct_used
FROM dba_temp_free_space
ORDER BY pct_used DESC;

PROMPT
PROMPT --- [3.3] FRA (Fast Recovery Area) ---
COLUMN name            FORMAT A40    HEADING 'Localizacao'
COLUMN space_limit_gb  FORMAT 99,990.99  HEADING 'Limite GB'
COLUMN space_used_gb   FORMAT 99,990.99  HEADING 'Usado GB'
COLUMN space_reclaimable_gb FORMAT 99,990.99 HEADING 'Recuperavel GB'
COLUMN pct_used        FORMAT 990.99  HEADING '% Usado'

SELECT name,
       ROUND(space_limit      /1024/1024/1024,2) space_limit_gb,
       ROUND(space_used       /1024/1024/1024,2) space_used_gb,
       ROUND(space_reclaimable/1024/1024/1024,2) space_reclaimable_gb,
       ROUND(space_used/NULLIF(space_limit,0)*100,2) pct_used
FROM v$recovery_file_dest;

PROMPT
PROMPT --- [3.4] Top 20 Segmentos por Tamanho ---
COLUMN owner         FORMAT A25   HEADING 'Owner'
COLUMN segment_name  FORMAT A40   HEADING 'Segmento'
COLUMN segment_type  FORMAT A15   HEADING 'Tipo'
COLUMN size_gb       FORMAT 999,990.999  HEADING 'Tamanho GB'

SELECT owner,
       segment_name,
       segment_type,
       ROUND(SUM(bytes)/1024/1024/1024,3) size_gb
FROM dba_segments
WHERE owner NOT IN (
  'SYS','SYSTEM','DBSNMP','OUTLN',
  'XDB','MDSYS','ORDSYS','CTXSYS',
  'WMSYS','OJVMSYS','LBACSYS','DVSYS'
)
GROUP BY owner, segment_name, segment_type
ORDER BY size_gb DESC
FETCH FIRST 20 ROWS ONLY;

-- =============================================================================
-- BLOCO 4 — ALTA DISPONIBILIDADE
-- =============================================================================
PROMPT
PROMPT ================================================================================
PROMPT  [4] ALTA DISPONIBILIDADE — DATA GUARD
PROMPT ================================================================================
PROMPT

PROMPT --- [4.1] Configuracao Data Guard ---
COLUMN db_unique_name     FORMAT A25   HEADING 'DB Unique Name'
COLUMN protection_mode    FORMAT A25   HEADING 'Protection Mode'
COLUMN protection_level   FORMAT A25   HEADING 'Protection Level'
COLUMN switchover_status  FORMAT A20   HEADING 'Switchover Status'
COLUMN dg_broker          FORMAT A10   HEADING 'Broker'
COLUMN guard_status       FORMAT A12   HEADING 'Guard Status'

SELECT db_unique_name,
       protection_mode,
       protection_level,
       switchover_status,
       dataguard_broker  dg_broker,
       guard_status
FROM v$database;

PROMPT
PROMPT --- [4.2] Data Guard Stats (lag / apply) ---
COLUMN stat_name    FORMAT A35   HEADING 'Metrica'
COLUMN stat_value   FORMAT A25   HEADING 'Valor'
COLUMN stat_unit    FORMAT A20   HEADING 'Unidade'
COLUMN computed_at  FORMAT A20   HEADING 'Calculado Em'

SELECT name        stat_name,
       value       stat_value,
       unit        stat_unit,
       TO_CHAR(time_computed,'DD/MM/YYYY HH24:MI') computed_at
FROM v$dataguard_stats
WHERE name IN (
  'transport lag',
  'apply lag',
  'apply finish time',
  'estimated startup time'
);

PROMPT
PROMPT --- [4.3] Status Managed Recovery e RFS ---
COLUMN process    FORMAT A10   HEADING 'Processo'
COLUMN status     FORMAT A15   HEADING 'Status'
COLUMN sequence#  FORMAT 9999999  HEADING 'Sequence#'
COLUMN delay_mins FORMAT 9999  HEADING 'Delay Min'
COLUMN thread#    FORMAT 999   HEADING 'Thread'

SELECT process, status, thread#, sequence#, delay_mins
FROM v$managed_standby
WHERE process IN ('MRP0','RFS','ARCH','LNS')
ORDER BY process;

PROMPT
PROMPT --- [4.4] Geracao de Archive Logs (ultimas 24h) ---
COLUMN inst_id    FORMAT 99    HEADING 'Inst'
COLUMN hora       FORMAT A15   HEADING 'Hora'
COLUMN qtd_arch   FORMAT 9999  HEADING 'Qtd Arch'
COLUMN mb_gerado  FORMAT 99,990.99  HEADING 'MB Gerado'

SELECT inst_id,
       TO_CHAR(first_time,'DD/MM/YYYY HH24') hora,
       COUNT(*)                               qtd_arch,
       ROUND(SUM(blocks*block_size)/1024/1024,2) mb_gerado
FROM gv$archived_log
WHERE first_time  >= SYSDATE - 1
  AND standby_dest = 'NO'
GROUP BY inst_id, TO_CHAR(first_time,'DD/MM/YYYY HH24')
ORDER BY inst_id, hora;

-- =============================================================================
-- BLOCO 5 — SCHEMAS E OBJETOS
-- =============================================================================
PROMPT
PROMPT ================================================================================
PROMPT  [5] SCHEMAS E OBJETOS
PROMPT ================================================================================
PROMPT

PROMPT --- [5.1] Schemas de aplicacao ---
COLUMN owner        FORMAT A25   HEADING 'Owner'
COLUMN total_obj    FORMAT 99999 HEADING 'Total Obj'
COLUMN tabelas      FORMAT 9999  HEADING 'Tabelas'
COLUMN indices      FORMAT 9999  HEADING 'Indices'
COLUMN procedures   FORMAT 9999  HEADING 'Procs'
COLUMN packages     FORMAT 9999  HEADING 'Packages'
COLUMN views        FORMAT 9999  HEADING 'Views'

SELECT owner,
       COUNT(*)                                       total_obj,
       SUM(DECODE(object_type,'TABLE'    ,1,0))      tabelas,
       SUM(DECODE(object_type,'INDEX'    ,1,0))      indices,
       SUM(DECODE(object_type,'PROCEDURE',1,0))      procedures,
       SUM(DECODE(object_type,'PACKAGE'  ,1,0))      packages,
       SUM(DECODE(object_type,'VIEW'     ,1,0))      views
FROM dba_objects
WHERE owner NOT IN (
  'SYS','SYSTEM','DBSNMP','OUTLN','XDB',
  'MDSYS','ORDSYS','CTXSYS','WMSYS',
  'OJVMSYS','LBACSYS','DVSYS','GSMADMIN_INTERNAL',
  'APPQOSSYS','DBSFWUSER','GGSYS','REMOTE_SCHEDULER_AGENT'
)
GROUP BY owner
ORDER BY total_obj DESC;

PROMPT
PROMPT --- [5.2] Objetos invalidos ---
COLUMN owner        FORMAT A25   HEADING 'Owner'
COLUMN object_type  FORMAT A20   HEADING 'Tipo'
COLUMN object_name  FORMAT A40   HEADING 'Objeto'
COLUMN status       FORMAT A10   HEADING 'Status'
COLUMN last_ddl     FORMAT A12   HEADING 'Ultimo DDL'

SELECT owner,
       object_type,
       object_name,
       status,
       TO_CHAR(last_ddl_time,'DD/MM/YYYY') last_ddl
FROM dba_objects
WHERE status != 'VALID'
  AND owner NOT IN (
    'SYS','SYSTEM','XDB','MDSYS','ORDSYS',
    'CTXSYS','WMSYS','OJVMSYS'
  )
ORDER BY owner, object_type, object_name;

PROMPT
PROMPT --- [5.3] Tabelas sem estatisticas ou desatualizadas (mais de 7 dias) ---
COLUMN owner          FORMAT A25   HEADING 'Owner'
COLUMN table_name     FORMAT A35   HEADING 'Tabela'
COLUMN last_analyzed  FORMAT A15   HEADING 'Ult Analise'
COLUMN num_rows       FORMAT 999,999,999  HEADING 'Num Rows'
COLUMN blocks         FORMAT 999,999      HEADING 'Blocks'

SELECT owner,
       table_name,
       TO_CHAR(last_analyzed,'DD/MM/YYYY') last_analyzed,
       num_rows,
       blocks
FROM dba_tables
WHERE owner NOT IN (
  'SYS','SYSTEM','DBSNMP','OUTLN','XDB',
  'MDSYS','ORDSYS','CTXSYS','WMSYS','OJVMSYS'
)
  AND (last_analyzed IS NULL OR last_analyzed < SYSDATE - 7)
  AND num_rows > 0
ORDER BY last_analyzed NULLS FIRST
FETCH FIRST 30 ROWS ONLY;

-- =============================================================================
-- BLOCO 6 — JOBS E BACKUP
-- =============================================================================
PROMPT
PROMPT ================================================================================
PROMPT  [6] JOBS E BACKUP
PROMPT ================================================================================
PROMPT

PROMPT --- [6.1] Jobs com falha nos ultimos 7 dias ---
COLUMN owner          FORMAT A20   HEADING 'Owner'
COLUMN job_name       FORMAT A35   HEADING 'Job Name'
COLUMN status         FORMAT A12   HEADING 'Status'
COLUMN inicio         FORMAT A18   HEADING 'Inicio'
COLUMN run_duration   FORMAT A15   HEADING 'Duracao'
COLUMN additional_info FORMAT A60  HEADING 'Detalhe Erro'

SELECT owner,
       job_name,
       status,
       TO_CHAR(actual_start_date,'DD/MM/YYYY HH24:MI') inicio,
       CAST(run_duration AS VARCHAR2(15))               run_duration,
       SUBSTR(additional_info,1,60)                     additional_info
FROM dba_scheduler_job_run_details
WHERE status != 'SUCCEEDED'
  AND actual_start_date > SYSDATE - 7
ORDER BY actual_start_date DESC;

PROMPT
PROMPT --- [6.2] Ultimos 10 backups RMAN ---
COLUMN session_key   FORMAT 99999     HEADING 'Key'
COLUMN input_type    FORMAT A25       HEADING 'Tipo Backup'
COLUMN status        FORMAT A15       HEADING 'Status'
COLUMN inicio        FORMAT A18       HEADING 'Inicio'
COLUMN fim           FORMAT A18       HEADING 'Fim'
COLUMN elapsed_min   FORMAT 99,990.99 HEADING 'Min'
COLUMN input_gb      FORMAT 9,990.99  HEADING 'Input GB'
COLUMN output_gb     FORMAT 9,990.99  HEADING 'Output GB'
COLUMN ratio         FORMAT 990.99    HEADING 'Comp Ratio'

SELECT session_key,
       input_type,
       status,
       TO_CHAR(start_time,'DD/MM/YYYY HH24:MI')  inicio,
       TO_CHAR(end_time  ,'DD/MM/YYYY HH24:MI')  fim,
       ROUND(elapsed_seconds/60,2)               elapsed_min,
       ROUND(input_bytes /1024/1024/1024,2)      input_gb,
       ROUND(output_bytes/1024/1024/1024,2)      output_gb,
       ROUND(compression_ratio,2)                ratio
FROM v$rman_backup_job_details
ORDER BY start_time DESC
FETCH FIRST 10 ROWS ONLY;

PROMPT
PROMPT --- [6.3] Blocos corrompidos conhecidos ---
COLUMN file#              FORMAT 9999   HEADING 'File#'
COLUMN block#             FORMAT 99999  HEADING 'Block#'
COLUMN blocks             FORMAT 9999   HEADING 'Blocks'
COLUMN corruption_type    FORMAT A20    HEADING 'Tipo Corrupcao'
COLUMN corruption_time    FORMAT A18    HEADING 'Detectado Em'

SELECT file#,
       block#,
       blocks,
       corruption_type,
       TO_CHAR(time,'DD/MM/YYYY HH24:MI') corruption_time
FROM v$database_block_corruption
ORDER BY time DESC;

-- =============================================================================
-- BLOCO 7 — PERFORMANCE ATUAL
-- =============================================================================
PROMPT
PROMPT ================================================================================
PROMPT  [7] PERFORMANCE ATUAL
PROMPT ================================================================================
PROMPT

PROMPT --- [7.1] Top 10 Wait Events (excluindo Idle) ---
COLUMN event          FORMAT A45   HEADING 'Evento'
COLUMN wait_class     FORMAT A20   HEADING 'Classe'
COLUMN total_waits    FORMAT 999,999,999  HEADING 'Total Waits'
COLUMN time_waited_s  FORMAT 999,999,990.99  HEADING 'Tempo Espera (s)'
COLUMN avg_wait_ms    FORMAT 999,990.99  HEADING 'Avg Wait (ms)'

SELECT event,
       wait_class,
       total_waits,
       ROUND(time_waited/100,2)                            time_waited_s,
       ROUND(time_waited/NULLIF(total_waits,0)*10,2)       avg_wait_ms
FROM v$system_event
WHERE wait_class NOT IN ('Idle')
ORDER BY time_waited DESC
FETCH FIRST 10 ROWS ONLY;

PROMPT
PROMPT --- [7.2] Sessoes bloqueadas agora ---
COLUMN inst_id           FORMAT 99    HEADING 'Inst'
COLUMN sid               FORMAT 9999  HEADING 'SID'
COLUMN serial#           FORMAT 99999 HEADING 'Serial#'
COLUMN username          FORMAT A20   HEADING 'Usuario'
COLUMN status            FORMAT A10   HEADING 'Status'
COLUMN sql_id            FORMAT A15   HEADING 'SQL ID'
COLUMN event             FORMAT A35   HEADING 'Evento Espera'
COLUMN blocking_session  FORMAT 9999  HEADING 'Bloq por SID'
COLUMN secs_waiting      FORMAT 99999 HEADING 'Seg Esperando'
COLUMN module            FORMAT A30   HEADING 'Modulo'

SELECT s.inst_id,
       s.sid,
       s.serial#,
       s.username,
       s.status,
       s.sql_id,
       s.event,
       s.blocking_session,
       s.seconds_in_wait  secs_waiting,
       s.module
FROM gv$session s
WHERE s.blocking_session IS NOT NULL
ORDER BY s.seconds_in_wait DESC;

PROMPT
PROMPT --- [7.3] Top 15 SQLs por Elapsed Time (AWR ultimas 24h) ---
PROMPT     ** Requer Diagnostics Pack licenciado **
PROMPT

COLUMN sql_id          FORMAT A15   HEADING 'SQL ID'
COLUMN elapsed_sec     FORMAT 999,999,990.99  HEADING 'Elapsed (s)'
COLUMN execs           FORMAT 999,999,999  HEADING 'Execucoes'
COLUMN sec_per_exec    FORMAT 999,990.9999 HEADING 'Seg/Exec'
COLUMN buffer_gets     FORMAT 999,999,999,999 HEADING 'Buffer Gets'
COLUMN cpu_sec         FORMAT 999,999,990.99  HEADING 'CPU (s)'

SELECT sql_id,
       ROUND(SUM(elapsed_time_delta)/1e6,2)                           elapsed_sec,
       SUM(executions_delta)                                           execs,
       ROUND(SUM(elapsed_time_delta)
             /NULLIF(SUM(executions_delta),0)/1e6,4)                  sec_per_exec,
       SUM(buffer_gets_delta)                                          buffer_gets,
       ROUND(SUM(cpu_time_delta)/1e6,2)                               cpu_sec
FROM dba_hist_sqlstat
WHERE snap_id >= (
  SELECT MAX(snap_id) - 24
  FROM dba_hist_snapshot
  WHERE dbid = (SELECT dbid FROM v$database)
)
GROUP BY sql_id
ORDER BY elapsed_sec DESC
FETCH FIRST 15 ROWS ONLY;

-- =============================================================================
-- BLOCO 8 — LICENCIAMENTO
-- =============================================================================
PROMPT
PROMPT ================================================================================
PROMPT  [8] LICENCIAMENTO — FEATURES EM USO
PROMPT ================================================================================
PROMPT

COLUMN feature_name    FORMAT A55   HEADING 'Feature'
COLUMN detected        FORMAT 999   HEADING 'Usos'
COLUMN currently_used  FORMAT A5    HEADING 'Ativo?'
COLUMN last_used       FORMAT A18   HEADING 'Ultimo Uso'
COLUMN feat_version    FORMAT A12   HEADING 'Versao'

SELECT name           feature_name,
       detected_usages detected,
       currently_used,
       TO_CHAR(last_usage_date,'DD/MM/YYYY HH24:MI') last_used,
       version        feat_version
FROM dba_feature_usage_statistics
WHERE detected_usages > 0
  AND name IN (
    'ADDM',
    'AWR Report',
    'Automatic SQL Tuning Advisor',
    'SQL Tuning Advisor',
    'SQL Access Advisor',
    'Active Data Guard - Real-Time Query',
    'Advanced Compression',
    'Partitioning',
    'Real Application Clusters',
    'Multitenant',
    'Transparent Data Encryption',
    'Label Security',
    'Database Vault',
    'Diagnostics Pack',
    'Tuning Pack',
    'Data Masking',
    'GoldenGate',
    'Oracle Data Guard',
    'Flashback Data Archive'
  )
ORDER BY name;

-- =============================================================================
-- BLOCO 9 — CONFIGURACAO DE REDO E ARCHIVE
-- =============================================================================
PROMPT
PROMPT ================================================================================
PROMPT  [9] REDO LOGS E ARCHIVE
PROMPT ================================================================================
PROMPT

PROMPT --- [9.1] Redo Log Groups ---
COLUMN grp        FORMAT 999    HEADING 'Grupo'
COLUMN members    FORMAT 999    HEADING 'Members'
COLUMN size_mb    FORMAT 9,990  HEADING 'Size MB'
COLUMN status     FORMAT A12    HEADING 'Status'
COLUMN archived   FORMAT A5     HEADING 'Arch?'
COLUMN thread#    FORMAT 999    HEADING 'Thread'

SELECT l.group#   grp,
       l.thread#,
       l.members,
       ROUND(l.bytes/1024/1024) size_mb,
       l.status,
       l.archived
FROM v$log l
ORDER BY l.thread#, l.group#;

PROMPT
PROMPT --- [9.2] Redo Log Members ---
COLUMN grp         FORMAT 999    HEADING 'Grupo'
COLUMN member      FORMAT A70    HEADING 'Membro'
COLUMN log_status  FORMAT A10    HEADING 'Status'

SELECT l.group#  grp,
       lf.member,
       lf.status log_status
FROM v$logfile lf
JOIN v$log l ON lf.group# = l.group#
ORDER BY l.group#, lf.member;

-- =============================================================================
-- BLOCO 10 — RESUMO DE RISCOS
-- =============================================================================
PROMPT
PROMPT ================================================================================
PROMPT  [10] RESUMO DE RISCOS IDENTIFICADOS
PROMPT ================================================================================
PROMPT

PROMPT --- Tablespaces acima de 80% de uso ---
SELECT tablespace_name,
       ROUND((total_mb - NVL(free_mb,0))/total_mb*100,2) pct_used,
       ROUND(NVL(free_mb,0),2) free_mb
FROM (
  SELECT df.tablespace_name,
         SUM(df.bytes)/1024/1024 total_mb,
         SUM(fs.bytes)/1024/1024 free_mb
  FROM dba_data_files df
  LEFT JOIN dba_free_space fs
    ON df.tablespace_name = fs.tablespace_name
   AND df.file_id         = fs.file_id
  GROUP BY df.tablespace_name
)
WHERE (total_mb - NVL(free_mb,0))/total_mb*100 >= 80
ORDER BY pct_used DESC;

PROMPT
PROMPT --- Objetos invalidos (contagem por owner) ---
SELECT owner, COUNT(*) objetos_invalidos
FROM dba_objects
WHERE status != 'VALID'
  AND owner NOT IN ('SYS','SYSTEM','XDB','MDSYS','ORDSYS','CTXSYS')
GROUP BY owner
ORDER BY objetos_invalidos DESC;

PROMPT
PROMPT --- Tabelas sem estatisticas (contagem por owner) ---
SELECT owner, COUNT(*) tabelas_sem_stats
FROM dba_tables
WHERE last_analyzed IS NULL
  AND owner NOT IN (
    'SYS','SYSTEM','DBSNMP','OUTLN','XDB',
    'MDSYS','ORDSYS','CTXSYS','WMSYS'
  )
GROUP BY owner
ORDER BY tabelas_sem_stats DESC;

PROMPT
PROMPT --- Sessoes bloqueadas no momento ---
SELECT COUNT(*) sessoes_bloqueadas
FROM gv$session
WHERE blocking_session IS NOT NULL;

PROMPT
PROMPT --- Falhas de backup nos ultimos 30 dias ---
SELECT status, COUNT(*) qtd
FROM v$rman_backup_job_details
WHERE start_time > SYSDATE - 30
GROUP BY status
ORDER BY qtd DESC;

-- =============================================================================
-- RODAPE
-- =============================================================================
PROMPT
PROMPT ================================================================================
PROMPT  FIM DO INVENTARIO
PROMPT  Arquivo gerado: &&arquivo.&&dt_arquivo..log
PROMPT ================================================================================

SPOOL OFF

SET FEEDBACK ON
SET VERIFY   ON
SET HEADING  ON