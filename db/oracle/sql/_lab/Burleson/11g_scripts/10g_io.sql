
col file_id heading 'File|ID' format 9999
col file_name heading 'File|Name'
col begin_time heading 'Begin Time'
col end_time heading 'End Time'
col physical_block_reads heading 'Physical|Block|Reads'
col physical_block_writes heading 'Physical|Block|Writes'
col average_read_time heading 'Average|Read|Time'
col average_write_time heading 'Average_write_time'
col average_write_time heading 'Average|Write|Time'
col physical_reads heading 'Physical|Reads'
col physical_writes heading 'Physical|Writes'
set lines 200 pages 55
ttitle '10g File IO Statistics'
spool 10g_io
select
        to_char(begin_time,'dd-MON-yy hh:mi') begin_time,
        to_char(end_time,'dd-MON-yy hh:mi') end_time,
        a.file_id,
        file_name,
        average_read_time,
        average_write_time,
        physical_reads,
        physical_writes,
        physical_block_reads,
        physical_block_writes
from
        sys.v_$filemetric_history a,
        sys.dba_data_files b
where
        a.file_id = b.file_id
order by
        1,3
/
spool off
ttitle off
set lines 80 pages 22
