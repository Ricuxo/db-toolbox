-- -----------------------------------------------------------------------------------
-- File Name    : http://www.oracle-base.com/dba/monitoring/index_usage.sql
-- Author       : Tim Hall
-- Description  : Shows the usage for the specified table indexes.
-- Call Syntax  : @index_usage (table-name) (index-name or all)
-- Last Modified: 04/02/2005
-- -----------------------------------------------------------------------------------
SET VERIFY OFF
SET LINESIZE 200

SELECT table_name,
       index_name,
       used,
       start_monitoring,
       end_monitoring
FROM   v$object_usage
WHERE  table_name = UPPER(NVL('&TABLE_NAME', TABLE_NAME))
AND    index_name = UPPER(NVL('&IDX_NAME', INDEX_NAME))
/
