/*  */
select 
   count(distinct hash_value) carteisan_statements, 
   count(*)                   total_cartesian_joins 
from  
   sys.v_$sql_plan 
where 
   options = 'CARTESIAN' 
and   
   operation like '%JOIN%' 
