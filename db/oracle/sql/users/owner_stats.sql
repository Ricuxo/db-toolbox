SET PAGESIZE 100
SET LINESIZE 200
SET FEEDBACK OFF

-- Formatação das colunas
COLUMN OWNER FORMAT A30
COLUMN LAST_ANALYZED FORMAT A30
COLUMN TOTAL_OBJECTS FORMAT 99999

-- Consulta para listar todos os owners, última coleta de estatísticas e contagem de objetos
SELECT 
    OWNER,
    MAX(LAST_ANALYZED) AS LAST_ANALYZED,
    COUNT(*) AS TOTAL_OBJECTS
FROM 
    DBA_TAB_STATISTICS
WHERE 
    OWNER NOT IN (
        'SYS', 'SYSTEM', 'DBSNMP', 'SYSMAN', 'OUTLN', 'MGMT_VIEW', 
        'ORDDATA', 'ORDPLUGINS', 'CTXSYS', 'XDB', 'WMSYS', 'ORDSYS', 
        'MDSYS', 'APEX_PUBLIC_USER', 'ANONYMOUS', 'FLOWS_FILES', 
        'EXFSYS', 'SQLTXPLAIN'
    )
    AND OWNER NOT LIKE 'APEX%'  -- Exclui usuários relacionados ao APEX
    AND OWNER NOT LIKE 'ORA%'   -- Exclui usuários internos iniciados com "ORA"
GROUP BY 
    OWNER
ORDER BY 
    OWNER;