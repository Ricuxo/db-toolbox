select segment_name table_name, sum(bytes)/(1024*1024) MBytes 
from dba_extents 
where segment_type='TABLE' 
and  segment_name ='&tabela' 
group by segment_name;