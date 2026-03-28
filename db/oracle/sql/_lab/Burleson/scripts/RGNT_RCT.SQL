/*  */
REM
REM FUNCTION:   SCRIPT FOR CAPTURING ROLE GRANTS
REM
REM This script must be run by a user with the DBA role.
REM
REM This script is intended to run with Oracle7.
REM
REM Running this script will create a script of all the grants 
REM of roles to users and other roles.  This created script, 
REM grant_roles.sql, must be run by a user with the DBA role.
REM 
REM Since role grants are not dependant on the schema that issued the grant, 
REM the grant_roles.sql script will not issue the grant of a role by the 
REM original grantor.  All grants will be issued by the user specified when 
REM running this script.
REM 
REM NOTE:  Grants made to 'SYS' are not captured.
REM 
REM        Only preliminary testing of this script was performed.  Be 
REM        sure to test it completely before relying on it.
REM
 column dbname new_value db noprint
select name dbname from v$database;
set verify off
set feedback off
set termout off
set echo off;
set pagesize 0
 
set termout on
select 'Creating role grant script...' from dual;
set termout off
 
spool rep_out\&db\grt_role.sql
 
select 'GRANT ' || lower(granted_role) || ' TO ' || lower(grantee) ||
       decode(admin_option,'YES',' WITH ADMIN OPTION;',';')
  from sys.dba_role_privs
  where grantee != 'SYS'
order by grantee
/
 
spool off
set verify on
set feedback on
set termout on
set echo on
set pagesize 22
clear columns
