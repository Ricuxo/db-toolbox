/*  */
REM FUNCTION:  SCRIPT FOR CAPTURING SYSTEM PRIVILEGE GRANTS
REM
REM FUNCTION: This script must be run by a user with the DBA role.
REM
REM This script is intended to run with Oracle7.
REM
REM FUNCTION: Running this script will in turn create a script of all the system
REM FUNCTION: privilege grants to users and roles.  This created script, 
REM FUNCTION: grant_sys_privs.sql must be run by a user with the DBA role or 
REM FUNCTION: with the 'GRANT ANY PRIVILEGE' system privilege. 
REM 
REM NOTE:  This script will not capture grants made to the Oracle
REM predefined roles, CONNECT, RESOURCE, DBA, EXP_FULL_DATABASE, or
REM IMP_FULL_DATABASE.
REM
REM Since system grants are not dependant on the schema that issued the grant,
REM the grant_sys_privs.sql script will not issue the grant of a role by the
REM original grantor.  All grants will be issued by the user specified when
REM running this script.
REM
REM Only preliminary testing of this script was performed.  Be sure to test
REM it completely before relying on it.
REM
column dbname new_value db noprint;
select name dbname from v$database;

set verify off
set feedback off
set termout off
set echo off;
set pagesize 0
 
set termout on
select 'Creating system privilege grant script...' from dual;
set termout off
/*
spool rep_out\&db\grt_sysp.sql
 
select 'GRANT ' || rpad(lower(privilege),30) || ' TO ' || lower(grantee) ||
       decode(admin_option,'YES',' WITH ADMIN OPTION;',';')
  from sys.dba_sys_privs
  where grantee not in ('CONNECT','RESOURCE','DBA',
                       'EXP_FULL_DATABASE','IMP_FULL_DATABASE')
order by grantee
/

*/
spool off
set verify on
set feedback on
set termout on
set echo on
set pagesize 22
clear columns
