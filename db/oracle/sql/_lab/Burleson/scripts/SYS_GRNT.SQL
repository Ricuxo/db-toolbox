/*  */
REM FUNCTION:   SCRIPT FOR CAPTURING ROLE SYSTEM GRANTS
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
set pagesize 0 embedded on


prompt Creating role sys grant script...

/*
column dbname new_value db noprint
select name dbname from v$database;
spool rep_out\&db\grt_sys.sql
 
select 'GRANT ' || lower(privilege) || ' TO ' || lower(grantee) ||
       decode(admin_option,'YES',' WITH ADMIN OPTION;',';')
  from sys.dba_sys_privs
  where grantee not in ('SYS','CONNECT','RESOURCE','DBA', 
	'EXP_FULL_DATABASE','IMP_FULL_DATABASE')  
        and grantee = upper('&grantee') 	  
order by grantee
/

*/
spool off
clear columns
set verify on feedback on termout on  pagesize 22 embedded off
