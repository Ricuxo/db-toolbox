/*  */
col owner format a10
col directory_path format a45
col directory_name format a14
set lines 80 heading on pages 47
@title80 'Dictionary Objects'
spool rep_out\&db\dict_rep
select * from dba_directories
;
spool off
ttitle off
set lines 80 pages 22
