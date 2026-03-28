/*  */
REM NAME        : PLAN_SYS_GRANTS.SQL
REM PURPOSE     : GENERATE DATABASE RESOURCE PLAN SYSTEM GRANTS REPORT
REM Revisions:
REM Date          Modified by     Reason for change
REM 15-May-1999     MIKE AULT     initial creation
REM
COLUMN privilege       FORMAT a30    HEADING 'Plan System Privilege'
COLUMN grantee         FORMAT a30    HEADING 'User or Role'
COLUMN admin_option    FORMAT a7     HEADING 'Admin?'
BREAK ON privilege
SET LINES 78 VERIFY OFF FEEDBACK OFF
START title80 'Resource Plan System Grants'
SPOOL rep_out\&&db\plan_sys_grants.lis
REM
SELECT 
     privilege, grantee, admin_option
FROM
    Dba_rsrc_manager_system_privs
ORDER BY
    Privilege;
SPOOL OFF
SET VERIFY ON FEEDBACK ON
TTITLE OFF

