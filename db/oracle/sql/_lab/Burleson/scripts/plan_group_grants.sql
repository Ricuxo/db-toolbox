/*  */
REM NAME        : PLAN_GROUP_GRANTS.SQL
REM PURPOSE     : GENERATE DATABASE RESOURCE PLAN GROUP GRANTS REPORT
REM Revisions:
REM Date          Modified by     Reason for change
REM 15-May-1999     MIKE AULT     initial creation
REM
COLUMN granted_group   FORMAT a30    HEADING 'Granted Group'
COLUMN grantee         FORMAT a30    HEADING 'User or Role'
COLUMN grant_option    FORMAT a7     HEADING 'Admin?'
COLUMN initial_group   FORMAT a8     HEADING 'Initial?'
BREAK ON granted_group
SET LINES 78 VERIFY OFF FEEDBACK OFF
START title80 'Resource Plan Group Grants'
SPOOL rep_out\&&db\plan_group_grants.lis
REM
SELECT 
     Granted_group, grantee, grant_option, initial_group
FROM
    Dba_rsrc_consumer_group_privs
ORDER BY
    Granted_group;
SPOOL OFF
SET VERIFY ON FEEDBACK ON
TTITLE OFF

