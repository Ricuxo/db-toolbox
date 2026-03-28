REM Flush all the old execution plans from the shared pool
REM Create package @?/rdbms/admin/dbmspool.sql

SET serveroutput on
SET pagesize 9999
SET linesize 155

VAR name varchar2(50)

ACCEPT sql_id - PROMPT 'Enter value for sql_id: '

BEGIN
   SELECT address || ',' || hash_value
     INTO :NAME
     FROM v$sqlarea
    WHERE sql_id LIKE '&sql_id';

   DBMS_SHARED_POOL.PURGE (:NAME, 'C', 1);
END;
/
 
