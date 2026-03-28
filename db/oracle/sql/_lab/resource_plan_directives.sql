select
   plan,
   group_or_subplan,
   status
from
   dba_rsrc_plan_directives
order by
   plan,
   group_or_subplan;