/*  */
REM  You must have direct select grants on the undelying tables
REM  for these views to be generated.

create or replace  view free_space (
	tablespace, 
	file_id, 
	pieces, 
	free_bytes, 
	free_blocks, 
	largest_bytes,
	largest_blks,
	fsfi) 
as
select 
	tablespace_name, 
	file_id, 
	count(*),
	sum(bytes), 
	sum(blocks),
	max(bytes), 
	max(blocks),
	sqrt(max(blocks)/sum(blocks))*(100/sqrt(sqrt(count(blocks)))) 
from 
	sys.dba_free_space
group by 
	tablespace_name, 
	file_id;

