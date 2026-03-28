/*  */
REM
REM     Name:      datafile.sql
REM     FUNCTION:  Document  file sizes and locations
REM     Use:       From SQLPLUS 
REM
clear computes
COLUMN FILE_NAME                FORMAT A46 Heading File
COLUMN TABLESPACE_NAME          FORMAT A16 HEADING Name
COLUMN MEG                      FORMAT 999,999.90
set pages 43 lines 79
ttitle 'DATABASE DATAFILES'
SPOOL datafile
BREAK ON TABLESPACE_NAME SKIP 1 ON REPORT
COMPUTE SUM OF MEG ON TABLESPACE_NAME
compute sum of meg on REPORT

SELECT
TABLESPACE_NAME, FILE_NAME, BYTES/1048576 MEG
FROM
DBA_DATA_FILES
ORDER BY
TABLESPACE_NAME
/

SPOOL OFF
clear columns
clear computes
pause Press enter to continue
