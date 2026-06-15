SELECT
    s.sid,
    s.serial#,
    s.username,
    s.machine,s.module,s.action,
    s.status,
    TO_CHAR(s.sql_exec_start, 'DD/MM HH24:MI:SS') AS sql_start,
    ROUND((SYSDATE - s.sql_exec_start) * 24 * 60, 1) AS min_exec,
    sq.rows_processed,
    s.event AS wait_event,
    CASE
        WHEN s.event = 'ON CPU' THEN 'Executando o comando no processador'
        WHEN s.event LIKE 'SQL*Net message to client%' THEN 'Retornando resultado ao Cliente (normal)'
        WHEN s.event LIKE 'SQL*Net message from client%' THEN 'Sessao ociosa aguardando proximo comando do Cliente'
        WHEN s.event LIKE 'SQL*Net more data to client%' THEN 'Resultado grande, ainda enviando dados ao Cliente'
        WHEN s.event LIKE 'SQL*Net more data from client%' THEN 'Recebendo dados grandes do Cliente (ex: INSERT em lote)'
        WHEN s.event LIKE 'db file sequential read%' THEN 'Lendo dados do disco usando indice (normal)'
        WHEN s.event LIKE 'db file scattered read%' THEN 'Lendo tabela inteira do disco (full table scan)'
        WHEN s.event LIKE 'direct path read%' THEN 'Lendo dados direto do disco sem usar cache'
        WHEN s.event LIKE 'direct path write%' THEN 'Gravando dados direto no disco sem usar cache'
        WHEN s.event LIKE 'Disk file operations I/O%' THEN 'Abrindo ou fechando arquivo no disco'
        WHEN s.event LIKE 'log file sync%' THEN 'Gravando confirmacao da transacao no disco (COMMIT)'
        WHEN s.event LIKE 'log file parallel write%' THEN 'Gravando log de transacao no disco'
        WHEN s.event LIKE 'cell smart table scan%' THEN 'Lendo tabela no storage Exadata (otimizado)'
        WHEN s.event LIKE 'cell single block read request%' THEN 'Lendo um bloco de dados no storage Exadata'
        WHEN s.event LIKE 'cell single block physical read%' THEN 'Lendo um bloco fisico no storage Exadata'
        WHEN s.event LIKE 'cell list of blocks read%' THEN 'Lendo varios blocos de dados no storage Exadata'
        WHEN s.event LIKE 'cell list of blocks physical read%' THEN 'Lendo varios blocos fisicos no storage Exadata'
        WHEN s.event LIKE 'cell disk open%' THEN 'Abrindo disco no storage Exadata'
        WHEN s.event LIKE 'gc buffer busy%' THEN 'Aguardando dados que estao em outro servidor do cluster (RAC)'
        WHEN s.event LIKE 'gc current block%' THEN 'Recebendo dados atualizados de outro servidor do cluster (RAC)'
        WHEN s.event LIKE 'gc cr%' THEN 'Recebendo copia de dados de outro servidor do cluster (RAC)'
        WHEN s.event LIKE 'PX Deq: Execute Reply%' THEN 'Sessao principal aguardando processos paralelos terminarem'
        WHEN s.event LIKE 'PX Deq: Execution Msg%' THEN 'Processo paralelo aguardando proxima tarefa do coordenador'
        WHEN s.event LIKE 'PX Deq: Table Q Normal%' THEN 'Processo paralelo recebendo dados para processar'
        WHEN s.event LIKE 'PX Deq Credit: send blkd%' THEN 'Processo paralelo pausado porque a fila de dados esta cheia'
        WHEN s.event LIKE 'enq: TX - row lock%' THEN 'BLOQUEADO - Outra sessao esta alterando a mesma linha'
        WHEN s.event LIKE 'enq: TX%' THEN 'BLOQUEADO - Aguardando outra transacao finalizar'
        WHEN s.event LIKE 'enq: TM%' THEN 'BLOQUEADO - Outra sessao esta alterando a estrutura da tabela'
        WHEN s.event LIKE 'enq:%' THEN 'BLOQUEADO - ' || s.event
        WHEN s.event LIKE 'row cache lock%' THEN 'BLOQUEADO - Aguardando acesso ao dicionario de dados'
        WHEN s.event LIKE 'library cache%' THEN 'BLOQUEADO - Aguardando compilacao de outro comando SQL'
        WHEN s.event LIKE 'buffer busy waits%' THEN 'Aguardando outra sessao liberar area de memoria'
        WHEN s.event LIKE 'free buffer waits%' THEN 'Sem espaco livre na memoria, aguardando liberacao'
        WHEN s.event LIKE 'read by other session%' THEN 'Outra sessao ja esta lendo os mesmos dados, aguardando'
        WHEN s.event LIKE 'Sync ASM rebalance%' THEN 'Storage redistribuindo dados entre discos (manutencao)'
        WHEN s.event LIKE 'latch%' THEN 'Contenção interna de memoria do banco'
        WHEN s.event LIKE 'cursor:%' THEN 'Preparando comando SQL para execucao'
        ELSE 'Outro evento: ' || s.event
    END AS wait_descricao,
    s.blocking_session AS blocking_sid,
    CASE
        WHEN s.blocking_session IS NULL THEN NULL
        WHEN s.event LIKE 'PX Deq%' THEN 'PARALELISMO (normal)'
        WHEN s.event LIKE 'enq: TX%' THEN 'LOCK REAL - TX'
        WHEN s.event LIKE 'enq: TM%' THEN 'LOCK REAL - TM'
        WHEN s.event LIKE 'enq:%' THEN 'LOCK REAL - ' || s.event
        WHEN s.event LIKE 'row cache lock%' THEN 'LOCK REAL'
        WHEN s.event LIKE 'library cache%' THEN 'LOCK REAL - LIBRARY'
        ELSE 'ESPERA (verificar)'
    END AS tipo_bloqueio,
    SUBSTR(sq.sql_text, 1, 150) AS sql_text
FROM v$session s
LEFT JOIN v$sql sq ON s.sql_id = sq.sql_id AND s.sql_child_number = sq.child_number
WHERE s.username IS NOT NULL
  AND s.username NOT IN (
    'SYS','SYSTEM','DBSNMP','SYSMAN','OUTLN','MDSYS','ORDSYS','EXFSYS',
    'DMSYS','WMSYS','CTXSYS','ANONYMOUS','XDB','ORDPLUGINS','OLAPSYS',
    'FLOWS_020100','FLOWS_FILES','TSMSYS','APPQOSSYS','DBSFWUSER',
    'GSMADMIN_INTERNAL','LBACSYS','REMOTE_SCHEDULER_AGENT','SYSBACKUP',
    'SYSDG','SYSKM','SYSRAC','AUDSYS','DIP','DVF','DVSYS','GGSYS',
    'GSMCATUSER','GSMUSER','OJVMSYS','XS$NULL','RDSADMIN',
    'RMAN$CATALOG','ORACLE_OCM','APEX_PUBLIC_USER','SPATIAL_CSW_ADMIN_USR','DATADOG'
  )
  AND s.status = 'ACTIVE'
ORDER BY
    CASE WHEN s.blocking_session IS NOT NULL AND s.event NOT LIKE 'PX Deq%' THEN 0 ELSE 1 END,
    min_exec DESC NULLS LAST;