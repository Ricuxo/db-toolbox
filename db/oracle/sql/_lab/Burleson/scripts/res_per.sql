/*  */
column max_limit format 999.99 heading "Max Percent|of Limit"
column cur_limit format 999.99 heading "Current Percent|of Limit"
column resource_name heading "Resource"
@title80 "Resource Utilization"
spool rep_out/&db/res_per
select 
   resource_name , 
   100*max_utilization/to_number(limit_value) max_limit, 
   100*current_utilization/to_number(limit_value) cur_limit
 from v$resource_limit
where limit_value not in ('UNLIMITED','0') and max_utilization > 0 and current_utilization>0;
spool off
ttitle off

