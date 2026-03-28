/*  */
REM FUNCTION:   SCRIPT FOR CAPTURING TABLE GRANTS
REM
REM This script must be run by a user with the DBA role.
REM
REM This script is intended to run with Oracle7.
REM
REM Running this script will create a script of all the grants 
REM of roles to users and other roles.  This created script, 
REM grt_sys.sql, must be run by a user with the DBA role.
REM 
REM Since role grants are not dependant on the schema that issued the
REM grant, the grt_role.sql script will not issue the grant of a role by 
REM the original grantor.  All grants will be issued by the user 
REM specified when running this script.
REM 
REM NOTE:  Grants made to 'SYS','CONNECT','RESOURCE','DBA',
REM 		'EXP_FULL_DATABASE','IMP_FULL_DATABASE' are not captured.
REM 
REM        Only preliminary testing of this script was performed.  Be 
REM        sure to test it completely before relying on it.
REM
set verify off feedback off termout off echo off pagesize 0 embedded on

set termout on
prompt Creating table grant script...
set termout off
 
break on line1
column dbname new_value db noprint
select value dbname from v$parameter where name=‘db_name’;
spool rep_out\&db\grt_cols.sql
 
select ‘CONNECT ‘||grantor||’/’||grantor line1,
'GRANT 
'||lower(privilege)||‘ ON ’||owner||’.’||table_name||’.’||column||'
‘||' TO '|| lower(grantee) ||
 decode(grantable,'YES',' WITH ADMIN OPTION;',';')
  from sys.dba_col_privs
  where grantee not in ('SYS','CONNECT','RESOURCE','DBA', 
	'EXP_FULL_DATABASE','IMP_FULL_DATABASE')   	  
order by grantor,grantee
/
spool off
set verify on feedback on termout on echo on pagesize 22 embedded off
clear columns
clear computes
clear breaks
rem exit
