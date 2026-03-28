/*  */
rem
rem FUNCTION: Generate a file storage statisitics report
rem
column file_name format a23 heading 'File|Name'
column file_id format 999999 heading 'File|Number'
column tablespace_name format a10 heading 'Tablespace'
column bytes format 999.99 heading 'Megs'
column status heading 'File|Status'
column value new_value block_size noprint
select value from sys.v_$parameter where name='db_block_size';
column blocks format 99,999 heading '&block_size byte|Blocks'
set feedback off echo off lines 79 pages 57
start title80 'File Storage Statistics Report'
spool rep_out\&db\file_sta
select file_name,file_id,status,tablespace_name,bytes/(1024*1024) bytes,
blocks from sys.dba_data_files
order by file_id
/
spool off
pause press enter/return to continue
clear columns
ttitle off
