--Procura objetos por nome ou tipo

SET VERIFY OFF

COL object_name FOR a30
COL owner FOR a15
col last_ddl_time for a15
col status for a30

SELECT owner, object_name, object_type, created, last_ddl_time, status
  FROM DBA_OBJECTS
 WHERE (UPPER(object_name) LIKE UPPER('%&1%') AND UPPER(object_type) LIKE NVL2('&2','%&2%','%'))
ORDER BY owner, object_type, object_name;
 
UNDEFINE 2
UNDEFINE 1
SET VERIFY ON