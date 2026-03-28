/*  */
REM
REM NAME        : DB_USER.SQL
REM
REM FUNCTION    : GENERATE USER_REPORT
REM Limitations : None
REM
REM Updates     : MRA 6/10/97 added Oracle8 account status
REM               MRA 5/14/99 Added Oracle8i Resource Group
REM
SET PAGESIZE 58  LINESIZE 131 FEEDBACK OFF
rem
COLUMN username                 FORMAT a10 HEADING User
COLUMN account_status           FORMAT a10 HEADING Status
COLUMN default_tablespace       FORMAT a15 HEADING Default
COLUMN temporary_tablespace     FORMAT a15 HEADING Temporary
COLUMN granted_role             FORMAT a21 HEADING Roles
COLUMN default_role             FORMAT a9  HEADING Default?
COLUMN admin_option             FORMAT a7  HEADING Admin?
COLUMN profile                  FORMAT a15 HEADING Profile
COLUMN initial_rsrc_consumer_group FORMAT a10 HEADING 'Resource|Group'
COLUMN lock_date                HEADING 'Date|Locked'
COLUMN expiry_date              HEADING 'Expiry_date'
rem
START title132 'ORACLE USER REPORT'
DEFINE output = rep_out\&db\db_user
BREAK ON username SKIP 1 ON account_status ON default_tablespace 
ON temporary_tablespace ON profile
SPOOL &output
rem 
SELECT a.username, 
       a.account_status,
       TO_CHAR(a.lock_date,'dd-mon-yyyy hh24:mi') lock_date,
       TO_CHAR(a.expiry_date,'dd-mon-yyyy hh24:mi') expiry_date,
       a.default_tablespace, 
       a.temporary_tablespace, 
       a.profile,
       b.granted_role, 
       b.admin_option, 
       b.default_role,
       a.initial_rsrc_consumer_group
FROM sys.dba_users a, 
     sys.dba_role_privs b
WHERE a.username = b.grantee 
ORDER BY username, 
         default_tablespace, 
         temporary_tablespace, 
         profile, 
         granted_role;
rem
SPOOL OFF
SET TERMOUT ON FLUSH ON FEEDBACK ON VERIFY ON
CLEAR COLUMNS
CLEAR BREAKS
PAUSE Press Enter to continue

