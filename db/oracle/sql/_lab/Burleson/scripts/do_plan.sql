/*  */
column query_plan format a60
select lpad(' ',2*level)||operation||' '||object_name||' cost '||to_char(cost) query_plan
from plan_table where statement_id = '&1'
connect by prior id=parent_id
start with id=0;
