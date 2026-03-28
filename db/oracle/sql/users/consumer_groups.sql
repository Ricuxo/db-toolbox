set lines 1000
column comments format a60

select
   consumer_group,
   comments
from
   dba_rsrc_consumer_groups
order by
   consumer_group
;
