/*  */
col id format 999 heading 'ID'
col name format a10 heading 'Name'
col block_size format 9,999,999 heading 'Blk.Size'
col advice_status heading 'Adv'
col size_for_estimate heading 'Size in|Meg' format 9,999,999
col estd_physical_reads heading 'Physical Reads|Saved' format 999,999,999,999
set lines 80 pages 47
ttitle 'Buffer Pool Advisor'
spool buffer_adv
select id,name,block_size,advice_status,size_for_estimate, size_factor "Factor",estd_physical_reads from v$db_cache_advice
/
spool off
clear columns
ttitle off
