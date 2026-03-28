@reset

set linesize 160
col ORACLE_HOME format a155

SELECT substr(file_spec,1,instr(file_spec,'lib')-2) ORACLE_HOME
  FROM dba_libraries
 WHERE library_name='DBMS_SUMADV_LIB'
/