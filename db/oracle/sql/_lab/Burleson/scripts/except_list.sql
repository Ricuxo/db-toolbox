/*  */
col owner format a10 head 'Owner'
col name format a30 head 'Object Name'
col text format a60 head 'Exception Text'
@title132 'User Defined Exceptions'
set lines 132 pages 47
spool rep_out\&db\exceptions
select owner,name,ltrim(text) text from dba_source 
where upper(text) like '%PRAGMA EXCEPTION_INIT%'
--and owner not in ('DISCO_ADMIN','DISCO_ADMIN_CM','DIS_DWRPT_ADMIN','DIS_DWRPT_ADMIN_V4',
and owner not in ('MRAULT','PERFSTAT','SYS','SYSTEM')
/
spool off
ttitle off
set lines 80 pages 22

