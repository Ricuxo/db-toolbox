/*  */
REM
REM NAME        : USER_EXPIRE.SQL
REM
REM FUNCTION    : GENERATE USER EXPIRY DATA REPORT
REM Limitations : None
REM
REM Updates     : MRA 5/22/99 Created
REM
COLUMN account_status           FORMAT a15 HEADING Status
COLUMN default_tablespace       FORMAT a14 HEADING Default
COLUMN temporary_tablespace     FORMAT a10 HEADING Temporary
COLUMN username                 FORMAT a12 HEADING User
COLUMN lock_date                FORMAT a11 HEADING 'Date|Locked'
COLUMN expiry_date              FORMAT a11 HEADING 'Expiry|Date'
COLUMN profile                  FORMAT a15 HEADING Profile
SET PAGESIZE 58  LINESIZE 131 FEEDBACK OFF
START title132 'ORACLE USER EXPIRATION REPORT'
BREAK ON username SKIP 1 ON default_tablespace ON temporary_tablespace ON profile ON account_status
SPOOL rep_out\&db\user_expire
rem 
SELECT username, 
       default_tablespace, 
       temporary_tablespace, 
       profile,
       account_status,
       TO_CHAR(lock_date,'dd-mon-yyyy') lock_date,
       TO_CHAR(expiry_date,'dd-mon-yyyy') expiry_date
FROM sys.dba_users
ORDER BY username, 
         default_tablespace, 
         temporary_tablespace, 
         profile,
         account_status;
rem
SPOOL OFF
SET TERMOUT ON FLUSH ON FEEDBACK ON VERIFY ON
CLEAR COLUMNS
CLEAR BREAKS
PAUSE Press Enter to continue


