/*  */
create or replace view sql_garbage as
select 
  b.username users, 
  sum(a.sharable_mem+a.persistent_mem) Garbage,
  to_number(null) good
from 
   sys.v_$sqlarea a, 
   dba_users b
where 
  (a.parsing_user_id = b.user_id and a.executions<=1)
group by b.username
union
select distinct
  b.username users, 
  to_number(null) garbage,
  sum(c.sharable_mem+c.persistent_mem) Good
from 
   dba_users b, 
   sys.v_$sqlarea c
where 
  (b.user_id=c.parsing_user_id and c.executions>1)
group by b.username;
--
