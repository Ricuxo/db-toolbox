/*
---  Rode o script conforme a versão do banco.
---  Os resultados vão te indicar:
---	 Se há registros antigos que não estão sendo limpos.
---	 Se há agendamento automático de limpeza.
---	 Qual a política de retenção em vigor.
*/

--- 11G

-- Validação do tipo de auditoria configurada
PROMPT === Tipo de auditoria configurado (audit_trail) ===
SHOW PARAMETER audit_trail;

-- Verificação da quantidade e período dos registros de auditoria
PROMPT === Quantidade de registros em SYS.AUD$ e intervalo de datas ===
SELECT COUNT(*) AS TOTAL_REGISTROS,
       MIN(NTIMESTAMP#) AS DATA_ANTIGA,
       MAX(NTIMESTAMP#) AS DATA_RECENTE
  FROM SYS.AUD$;

-- Tamanho ocupado pela tabela de auditoria
PROMPT === Tamanho da tabela SYS.AUD$ em MB ===
SELECT SEGMENT_NAME, BYTES/1024/1024 AS TAM_MB
  FROM DBA_SEGMENTS
 WHERE SEGMENT_NAME = 'AUD$'
   AND OWNER = 'SYS';

-- Validação se há agendamento de limpeza com DBMS_AUDIT_MGMT
PROMPT === Eventos de limpeza programados ===
SELECT * FROM DBA_AUDIT_MGMT_CLEAN_EVENTS;

-- Último timestamp de arquivamento definido
PROMPT === Último timestamp de arquivamento de auditoria ===
SELECT * FROM DBA_AUDIT_MGMT_LAST_ARCH_TS;


--- 12C

-- Confirmar se auditoria unificada está ativada
PROMPT === Auditoria Unificada está ativada? ===
SELECT VALUE AS UNIFIED_AUDIT_ENABLED
  FROM V$OPTION
 WHERE PARAMETER = 'Unified Auditing';

-- Verificação de dados na trilha unificada
PROMPT === Quantidade de registros em UNIFIED_AUDIT_TRAIL e intervalo de datas ===
SELECT COUNT(*) AS TOTAL_REGISTROS,
       MIN(EVENT_TIMESTAMP) AS DATA_ANTIGA,
       MAX(EVENT_TIMESTAMP) AS DATA_RECENTE
  FROM UNIFIED_AUDIT_TRAIL;

-- Validação se há eventos de limpeza programados
PROMPT === Eventos de limpeza programados ===
SELECT * FROM DBA_AUDIT_MGMT_CLEAN_EVENTS;

-- Último timestamp de arquivamento definido
PROMPT === Último timestamp de arquivamento de auditoria ===
SELECT * FROM DBA_AUDIT_MGMT_LAST_ARCH_TS;

-- Se quiser ver os jobs ativos:
PROMPT === Jobs de limpeza de auditoria ===
SELECT JOB_NAME, STATUS, REPEAT_INTERVAL
  FROM DBA_SCHEDULER_JOBS
 WHERE JOB_NAME LIKE '%PURGE%'
   AND JOB_ACTION LIKE '%AUDIT_MGMT%';




