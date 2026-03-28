/*  */
REM NAME        : RESOURCE_PLAN.SQL
REM PURPOSE     : GENERATE DATABASE RESOURCE PLAN REPORT
REM Revisions:
REM Date          Modified by     Reason for change
REM 15-May-1999     MIKE AULT     initial creation
REM
COLUMN plan                FORMAT a12      HEADING 'Plan|Name'
COLUMN cpu_method1         FORMAT a10      HEADING 'CPU|Method'
COLUMN mandatory1          FORMAT a4       HEADING 'Man?'
COLUMN num_plan_directives FORMAT 9999     HEADING 'Num|Directives'
COLUMN group_or_subplan    FORMAT a15      HEADING 'Group or|Subplan Name'
COLUMN type                FORMAT a8       HEADING 'Group or|Subplan'
COLUMN cpu_method2         FORMAT a15      HEADING 'CPU|Method'
COLUMN mandatory2          FORMAT a4       HEADING 'Man?'
COLUMN plan2 NOPRINT
REM
SET LINES 78 VERIFY OFF FEEDBACK OFF
BREAK ON plan on cpu_method1 on mandatory1 on num_plan_directives
START title80 'Resource Plan Report'
SPOOL rep_out\&&db\resource_plan.lis
REM
SELECT DISTINCT
      decode(b.plan,'',a.plan,b.plan) plan,
      b.plan plan2,
      a.cpu_method cpu_method1,
      a.mandatory mandatory1,
      decode(b.group_or_subplan,'',d.consumer_group||' CG',b.group_or_subplan) group_or_subplan,
      DECODE(b.type,'CONSUMER_GROUP','GROUP',b.type) type,
      decode(c.cpu_method,'',d.cpu_method||' CG',c.cpu_method) cpu_method2,
      decode(c.mandatory,'',d.mandatory||' CG',c.mandatory) mandatory2
FROM
     Dba_rsrc_plans a, dba_rsrc_plan_directives b, dba_rsrc_plans c,
     dba_rsrc_consumer_groups d
WHERE
     a.plan=b.plan
     AND ((b.group_or_subplan = c.plan OR b.group_or_subplan=d.consumer_group))
ORDER BY
     2,5;
SPOOL OFF
CLEAR COLUMNS
SET VERIFY ON FEEDBACK ON
TTITLE OFF

