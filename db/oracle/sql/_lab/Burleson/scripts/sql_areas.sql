/*  */
break on users on report
compute sum of areas on report 
select
  b.username,
  count(1) areas
from
   sys.v_$sqlarea a,
   dba_users b
where
  (a.parsing_user_id = b.user_id)
group by username
/
