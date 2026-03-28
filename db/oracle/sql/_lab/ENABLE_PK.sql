Segue script para habilitação das chaves-primarias em tabelas.

 SET PAGESIZE 0
SET FEEDBACK OFF
SET VERIFY OFF

SPOOL temp.sql

SELECT 'ALTER TABLE "' || a.table_name || '" ENABLE PRIMARY KEY;'
FROM   all_constraints a
WHERE  a.constraint_type = 'P'
AND     a.owner            = Upper('&2')
AND     a.table_name      = DECODE(Upper('&1'),'ALL',a.table_name,Upper('&1'));

SPOOL OFF

SET PAGESIZE 14
SET FEEDBACK ON
SET VERIFY ON
