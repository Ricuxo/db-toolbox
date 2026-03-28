/*  */
col value noprint new_value block_size
select value from v$parameter where name='db_block_size';
@title80 'RECYCLE Pool Objects'
break on report
compute sum of meg on report
spool rep_out\&db\keep_pool_obj
select table_name object, blocks*&&block_size/(1024*1024) meg from dba_tables where buffer_pool='RECYCLE'
union
select index_name object, leaf_blocks*&&block_size/(1024*1024) meg from dba_indexes where buffer_pool='RECYCLE'
/
spool off
ttitle off
clear computes
clear breaks
