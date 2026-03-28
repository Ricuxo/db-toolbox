/*  */
REM NAME        : PLAN_DIRECTIVE.SQL
REM PURPOSE     : GENERATE DATABASE RESOURCE PLAN DIRECTIVES REPORT
REM Revisions:
REM Date          Modified by     Reason for change
REM 15-May-1999     MIKE AULT     initial creation
REM
REM NAME        : RESOURCE_PLAN.SQL
REM PURPOSE     : GENERATE DATABASE RESOURCE PLAN REPORT
REM Revisions:
REM Date          Modified by     Reason for change
REM 15-May-1999     MIKE AULT     initial creation
REM
COLUMN plan                     FORMAT a10     HEADING 'Plan|Name'
COLUMN cpu_method1              FORMAT a30     HEADING 'CPU|Method'
COLUMN mandatory1               FORMAT a4      HEADING 'Man?'
COLUMN num_plan_directives      FORMAT 9999    HEADING 'Num|Directives'
COLUMN group_or_subplan         FORMAT a12     HEADING 'Group or|Subplan Name'
COLUMN type                     FORMAT a8      HEADING 'Group or|Subplan'
COLUMN cpu_method2              FORMAT a30     HEADING 'CPU|Method'
COLUMN mandatory2               FORMAT a4      HEADING 'Man?'
COLUMN cpu_p1                   FORMAT 99999   HEADING 'CPU1%'
COLUMN cpu_p2                   FORMAT 99999   HEADING 'CPU2%'
COLUMN cpu_p3                   FORMAT 99999   HEADING 'CPU3%'
COLUMN cpu_p4                   FORMAT 99999   HEADING 'CPU4%'
COLUMN cpu_p5                   FORMAT 99999   HEADING 'CPU5%'
COLUMN cpu_p6                   FORMAT 99999   HEADING 'CPU6%'
COLUMN cpu_p7                   FORMAT 99999   HEADING 'CPU7%'
COLUMN cpu_p8                   FORMAT 99999   HEADING 'CPU8%'
COLUMN parallel_degree_limit_p1 FORMAT 999999  HEADING 'Par|Degree'
REM
SET LINES 130 VERIFY OFF FEEDBACK OFF
BREAK ON plan on cpu_method1 on mandatory1 on num_plan_directives
START title132 'Resource Plan Directives Report'
SPOOL rep_out\&&db\resource_plan.lis
REM
SELECT
      a.plan,
      a.cpu_method cpu_method1,
      a.mandatory mandatory1,
      b.group_or_subplan,
      b.type,
      c.cpu_method cpu_method2,
      c.mandatory mandatory2
      b.cpu_p1,b.cpu_p2,b.cpu_p3,b.cpu_p4,
      b.cpu_p5,b.cpu_p6,b.cpu_p7,b.cpu_p8,
      parallel_degree_limit_p1

FROM
     Dba_rsrc_palns a, dba_rsrc_plan_directives b, dba_rsrc_plans c
WHERE
     a.plan=b.plan
     AND (b.type(+)='SUBPLAN' AND b.group_or_subplan = a.plan) 
ORDER BY
     a.plan;
SPOOL OFF
CLEAR COLUMNS
SET VERIFY ON FEEDBACK ON
TTITLE OFF

