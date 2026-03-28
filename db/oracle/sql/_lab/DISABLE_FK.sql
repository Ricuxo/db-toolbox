--Segue script para desabilitar todas as chave-estrangeiras (FK) de um schema.

 SET PAGESIZE 0
SET FEEDBACK OFF
SET VERIFY OFF

SPOOL temp.sql

SELECT 'ALTER TABLE "' || a.table_name || '" DISABLE CONSTRAINT "' || a.constraint_name || '";'
FROM   all_constraints a
WHERE  a.constraint_type = 'R'
AND     a.table_name      = DECODE(Upper('&1'),'ALL',a.table_name,Upper('&1'))
AND     a.owner            = Upper('&2');

SPOOL OFF

-- Comment out following line to prevent immediate run
@temp.sql

SET PAGESIZE 14
SET FEEDBACK ON
SET VERIFY ON