REM 	Identifica o segment/objeto afetado pelo bloco danificado <file_id> <block>
REM     
REM

SELECT owner, segment_name, segment_type, relative_fno
from dba_extents
where file_id = '&file_id'
and &block between block_id and block_id + blocks -1;

