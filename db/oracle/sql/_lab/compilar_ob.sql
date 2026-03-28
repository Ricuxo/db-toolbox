COLUMN owner format a1 noprint
COLUMN object_name format a1 noprint
COLUMN order_col format a1 noprint
COLUMN cmd format a132

SET heading off
SET pagesize 0
SET linesize 180
SET echo off
SET feedback off

SPOOL recompile-sql.sql

SELECT 'set echo on'
  FROM dual;

SELECT 'spool recompile.lis'
  FROM dual;

SELECT DISTINCT 'alter session set current_schema=' ||
                owner ||
                ';' cmd,
                owner,
                1 order_col,
                NULL object_name
  FROM dba_objects
 WHERE status = 'INVALID'
   AND object_type IN ('PACKAGE',
                       'PACKAGE BODY',
                       'VIEW',
                       'PROCEDURE',
                       'FUNCTION',
                       'TRIGGER')
UNION
SELECT 'ALTER ' ||
       DECODE (
          object_type,
          'PACKAGE BODY', 'PACKAGE',
          object_type
       ) ||
       ' ' ||
       owner ||
       '.' ||
       object_name ||
       ' COMPILE' ||
       DECODE (
          object_type,
          'PACKAGE BODY', ' BODY',
          ''
       ) ||
       ';' cmd,
       owner,
       2 order_col,
       object_name
  FROM dba_objects outer
 WHERE status = 'INVALID'
   AND object_type IN ('PACKAGE',
                       'PACKAGE BODY',
                       'VIEW',
                       'PROCEDURE',
                       'FUNCTION',
                       'TRIGGER')
   AND  ( object_type <>
             'PACKAGE BODY'
       OR NOT EXISTS ( SELECT NULL
                         FROM dba_objects
                        WHERE owner =
                                 outer.owner
                          AND object_name =
                                 outer.object_name
                          AND object_type =
                                 'PACKAGE'
                          AND status =
                                 'INVALID')
          )
 ORDER BY 2, 3, 4
/


REM select 'exit;' from dual;
SPOOL off;

SET heading on
SET feedback on
SET pagesize 9999
SET linesize 80
