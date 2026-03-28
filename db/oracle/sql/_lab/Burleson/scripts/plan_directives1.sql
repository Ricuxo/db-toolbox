/*  */
REM NAME        : PLAN_DIRECTIVES.SQL
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
COLUMN plan                     FORMAT a11     HEADING 'Plan|Name'
COLUMN cpu_method1              FORMAT a8      HEADING 'CPU|Method'
COLUMN mandatory1               FORMAT a3      HEADING 'Man|?'
COLUMN num_plan_directives      FORMAT 999     HEADING 'Num|Dir'
COLUMN group_or_subplan         FORMAT a14     HEADING 'Group or|Subplan Name'
COLUMN type                     FORMAT a5      HEADING 'Type'
COLUMN cpu_method2              FORMAT a8      HEADING 'CPU|Method'
COLUMN mandatory2               FORMAT a3      HEADING 'Man|?'
COLUMN cpu_p1                   FORMAT 999     HEADING 'CPU|1%'
COLUMN cpu_p2                   FORMAT 999     HEADING 'CPU|2%'
COLUMN cpu_p3                   FORMAT 999     HEADING 'CPU|3%'
COLUMN cpu_p4                   FORMAT 999     HEADING 'CPU|4%'
COLUMN cpu_p5                   FORMAT 999     HEADING 'CPU|5%'
COLUMN cpu_p6                   FORMAT 999     HEADING 'CPU|6%'
COLUMN cpu_p7                   FORMAT 999     HEADING 'CPU|7%'
COLUMN cpu_p8                   FORMAT 999     HEADING 'CPU|8%'
COLUMN parallel_degree_limit_p1 FORMAT 999     HEADING 'Par|Deg'
REM
SET LINES 100 VERIFY OFF FEEDBACK OFF
BREAK ON plan on cpu_method1 on mandatory1 on num_plan_directives
START title132 'Resource Plan Directives Report'
SPOOL rep_out\&&db\plan_directives.lis
REM
SELECT DISTINCT
      a.plan,
      a.cpu_method cpu_method1,
      a.mandatory mandatory1,
      b.group_or_subplan,
      DECODE(b.type,'CONSUMER_GROUP','GROUP',b.type) type,
      c.cpu_method cpu_method2,
      c.mandatory mandatory2,
      b.cpu_p1,b.cpu_p2,b.cpu_p3,b.cpu_p4,
      b.cpu_p5,b.cpu_p6,b.cpu_p7,b.cpu_p8,
      parallel_degree_limit_p1
FROM
     dba_rsrc_plans a, dba_rsrc_plan_directives b, dba_rsrc_plans c,
     dba_rsrc_consumer_groups d
WHERE
     a.plan=b.plan
     AND ((b.group_or_subplan = c.plan OR b.group_or_subplan=d.consumer_group))
ORDER BY
     1,4,5;
SPOOL OFF
CLEAR COLUMNS
SET VERIFY ON FEEDBACK ON
TTITLE OFF

