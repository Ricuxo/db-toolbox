-- -----------------------------------------------------------------------------------
-- File Name    : https://oracle-base.com/dba/monitoring/unusable_indexes.sql
-- Author       : Tim Hall
-- Description  : Displays unusable indexes for the specified schema or all schemas.
-- Requirements : Access to the DBA views.
-- Call Syntax  : @unusable_indexes (schema-name or all)
-- Last Modified: 28/01/2018
-- -----------------------------------------------------------------------------------
SET VERIFY OFF LINESIZE 200

COLUMN owner FORMAT A30
COLUMN index_name FORMAT A30
COLUMN table_owner FORMAT A30
COLUMN table_name FORMAT A30

SELECT 'ALTER INDEX ' || OWNER || '.' ||
INDEX_NAME || ' REBUILD ' ||
' TABLESPACE ' || TABLESPACE_NAME || ';'
FROM DBA_INDEXES
WHERE STATUS='UNUSABLE'
UNION
SELECT 'ALTER INDEX ' || INDEX_OWNER || '.' ||
INDEX_NAME ||
' REBUILD PARTITION ' || PARTITION_NAME ||
' TABLESPACE ' || TABLESPACE_NAME || ';'
FROM DBA_IND_PARTITIONS
WHERE STATUS='UNUSABLE'
UNION
SELECT 'ALTER INDEX ' || INDEX_OWNER || '.' ||
INDEX_NAME ||
' REBUILD SUBPARTITION '||SUBPARTITION_NAME||
' TABLESPACE ' || TABLESPACE_NAME || ';'
FROM DBA_IND_SUBPARTITIONS
WHERE STATUS='UNUSABLE';
