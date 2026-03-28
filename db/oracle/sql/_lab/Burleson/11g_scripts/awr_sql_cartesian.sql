/*  */
select * 
from 
   sys.v_$sql 
where 
   hash_value in 
      (select hash_value 
       from 
          sys.v_$sql_plan 
       where 
          options = 'CARTESIAN' 
          and
          operation LIKE '%JOIN%' ) 
order by hash_value; 
