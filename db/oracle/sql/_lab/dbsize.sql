set pagesize 999
set timing off
set feedback off

COL "REGULAR_TBS GB" FORMAT A32
COL "TEMP_TBS GB" FORMAT A32

COLUMN DUMMY GB;
COMPUTE SUM LABEL 'TOTAL' OF GB ON TYPE;
BREAK ON TYPE SKIP 1;

@@cls
prompt
prompt
prompt ************************************************************************************
prompt
prompt

SELECT 'REGULAR' TYPE, TABLESPACE_NAME "REGULAR_TBS GB", ROUND(SUM(BYTES/1024/1024/1024), 2) GB 
  FROM DBA_DATA_FILES
 GROUP BY TABLESPACE_NAME
/

prompt
prompt

SELECT 'TEMP' TYPE, TABLESPACE_NAME "TEMP_TBS GB", ROUND(SUM(BYTES/1024/1024/1024), 2) GB
  FROM DBA_TEMP_FILES
 GROUP BY TABLESPACE_NAME
/

prompt
prompt

SELECT 'REDOLOG' TYPE, GROUP#, MEMBERS, ROUND(SUM(BYTES/1024/1024), 2) MB, ROUND(SUM(BYTES/1024/1024/1024), 2) GB
  FROM V$LOG
 GROUP BY GROUP#, MEMBERS
 ORDER BY GROUP#
/

prompt
prompt
prompt ************************************************************************************
prompt
prompt

set timing on
set feedback on
clear breaks
clear computes