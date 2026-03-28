select owner, table_name, nvl(num_rows,-1) 
from all_tables 
order by nvl(num_rows,-1) desc