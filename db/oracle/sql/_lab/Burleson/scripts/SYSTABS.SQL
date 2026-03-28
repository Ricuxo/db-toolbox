/*  */
rem systabs.sql
rem report on non-sys owned tables in SYSTEM tablespace
rem M. Ault 6/5/96 TRECOM
rem
column owner format a15
column table_name format a30
column tablespace_name format a10
set pages 48 lines 80 feedback off verify off
start title80 'Non-SYS Owned Tables in SYSTEM'
spool rep_out/&db/nonsys
select owner,table_name,tablespace_name
from dba_tables 
where tablespace_name='SYSTEM' and owner !='SYS'
/
spool off
set pages 22 lines 80 feedback on verify on
clear columns
ttitle off
