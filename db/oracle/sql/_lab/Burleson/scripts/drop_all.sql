/*  */
/*
set pages 0 
set lines 132
set verify off feedback off echo off
spool drop_all_files.sh
select 'rm '||name from v$datafile
union
select 'rm '||name from v$tempfile
union
select 'rm '||member from v$logfile
union 
select 'rm '||name from v$controlfile
/
*/
spool off
