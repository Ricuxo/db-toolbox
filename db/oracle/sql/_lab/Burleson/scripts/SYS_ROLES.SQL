/*  */
REM
REM NAME        : sys_role.SQL
REM PURPOSE     : GENERATE SYSTEM GRANTS and ROLES REPORT
REM USE         : CALLED BY SQLPLUS
REM Limitations : None
REM Revisions   :
REM Date           Modified by  Reason for change
REM 08-Apr-1993    MIKE AULT     INITIAL CREATE
REM 10-Jun-1997    Mike Ault     Update to Oracle8
REM 15-May-1999    Mike Ault     No changes for Oracle8i
REM
SET FLUSH OFF TERM OFF PAGESIZE 58  LINESIZE 78
COLUMN grantee           HEADING 'User or Role'
COLUMN admin_option      HEADING Admin?
START title80 'SYSTEM GRANTS AND ROLES REPORT'
DEFINE output = rep_out\&&db\role_report
SPOOL &output
SELECT 
     grantee, 
     privilege, 
     admin_option 
FROM 
     sys.dba_sys_privs
GROUP BY 
     grantee;
SPOOL OFF
CLEAR COLUMNS
SET TERM ON FLUSH ON
TTITLE OFF

