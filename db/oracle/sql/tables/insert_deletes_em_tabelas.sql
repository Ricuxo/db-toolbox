select inserts, updates, deletes, PARTITION_NAME from dba_tab_modifications where table_name='CREDOR_SRS';

select table_name, last_analyzed, stale_stats,PARTITION_NAME 
from dba_tab_statistics 
where table_name='CONSULTA_REALIZADA_DETALHE' AND PARTITION_NAME in ('SPCJAVA_DATA_DCA_201909','SPCJAVA_DATA_DCA_201910','SPCJAVA_DATA_DCA_201911')
order by PARTITION_NAME;



SET LONG 1000000
SET LONGCHUNKSIZE 100000 
SET SERVEROUTPUT ON
SET LINE 300
SET PAGES 1000

DECLARE
  v_tname   VARCHAR2(128) := 'CONSULTA_REALIZADA_DETALHE';
  v_ename   VARCHAR2(128) := NULL;
  v_report  CLOB := NULL;
  v_script  CLOB := NULL;
BEGIN
  v_tname  := DBMS_STATS.CREATE_ADVISOR_TASK(v_tname);
  v_ename  := DBMS_STATS.EXECUTE_ADVISOR_TASK(v_tname);
  v_report := DBMS_STATS.REPORT_ADVISOR_TASK(v_tname);
  DBMS_OUTPUT.PUT_LINE(v_report);
END;
/


select DBMS_STATS.SCRIPT_ADVISOR_TASK('CONSULTA_REALIZADA_DETALHE') from dual;