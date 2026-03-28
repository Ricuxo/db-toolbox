select a.tablespace_name, a.file_name,(b.maximum+c.blocks-1)*d.db_block_size highwater
from dba_data_files a,(select file_id,max(block_id)
     maximum from dba_extents group by file_id) b ,dba_extents c ,
     (select value db_block_size from v$parameter
     where name='db_block_size') d
where a.file_id = b.file_id
      and c.file_id = b.file_id
      and c.block_id = b.maximum
order by a.tablespace_name,a.file_name;