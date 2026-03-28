/*  */
rem h_ratio := ((db_gets+con_gets)/(db_gets+con_gets+p_reads)); 

select name,((db_block_gets+consistent_gets)/(db_block_gets+consistent_gets+physical_reads)) hit_ratio
from v$buffer_pool_statistics;
