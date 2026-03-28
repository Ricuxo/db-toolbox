REM Gera DDL de partição existentes
REM

SET SERVEROUTPUT ON SIZE 1000000

BEGIN
   FOR r IN (SELECT   table_owner, table_name, partition_name, high_value,
                      tablespace_name
                 FROM dba_tab_partitions
                WHERE table_name = '&table_name'
                AND table_owner='&owner'
             ORDER BY partition_position)
   LOOP
      DBMS_OUTPUT.put_line (   'ALTER TABLE '
                            || r.table_owner
                            || '.'
                            || r.table_name
                            || ' '
                            || chr (10)
                            || ' ADD PARTITION '
                            || r.partition_name
                            || ' values less than '
                            || chr (10)
                            || ' ('
                            || r.high_value
                            || ')'
                            || chr (10)
                            || ' TABLESPACE '
                            || r.tablespace_name
                           );
      DBMS_OUTPUT.put_line (' ');
      DBMS_OUTPUT.put_line ('/');
   END LOOP;
END;
/