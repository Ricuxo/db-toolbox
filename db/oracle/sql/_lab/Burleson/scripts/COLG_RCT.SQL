/*  */
REM COLG_RCT.SQL
REM
REM FUNCTION:   SCRIPT FOR CAPTURING TABLE COLUMN GRANTS
REM
REM This script must be run by a user with the DBA role.
REM
REM This script is intended to run with Oracle7.
REM
REM Running this script will create a script of all the grants 
REM of roles to users and other roles.  This created script, 
REM grt_tabc.sql, must be run by a user with the DBA role.
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
set heading off

set termout on
prompt Creating table grant script...
set termout off
 
break on grantor
column dbname new_value db noprint
select value dbname from v$parameter where name=‘db_name’;
spool rep_out\&db\grt_tabc.sql
 
select 'connect '||grantor||'/'||grantor line1,
'grant
'||lower(privilege)||' on '||owner||'.'||table_name||'.'||column_name||'
'||' to '||lower(grantee)||
decode(grantable,'YES',' WITH ADMIN OPTION;',';')
 from sys.dba_col_privs
where grantee not in ('SYS','CONNECT','RESOURCE','DBA',
'EXP_FULL_DATABASE','IMP_FULL_DATABASE')
order by grantor,grantee
/
spool off
exit
