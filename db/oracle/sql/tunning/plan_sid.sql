-- get plan 10g on sql_id
set lin 150
set pages 70

SELECT   p.plan_table_output
  FROM   v$session s,
         table (DBMS_XPLAN.display_cursor (s.sql_id, s.sql_child_number)) p
 WHERE   s.sid = &1
/
