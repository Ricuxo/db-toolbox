/*  */
REM
REM role_rct.sql
REM
REM FUNCTION: SCRIPT FOR CREATING ROLES
REM
REM This script must be run by a user with the DBA role.
REM
REM This script is intended to run with Oracle7.
REM
REM Running this script will in turn create a script to build all the 
REM roles in the database.  This created file, create_roles.sql, can  
REM be run by any user with the DBA role or with 'CREATE ROLE' system 
REM privilege.
REM
REM Since it is not possible to create a role under a specific schema, it is 
REM essential that the original creator be granted 'ADMIN' option to the role.
REM Therefore, such grants will be made at the end of the create_roles.sql
REM script.  Since it is not possible to distinguish the creator from someone 
REM who was simply granted 'WITH ADMIN OPTION', all grants will be spooled.
REM In addition, the user who creates the role is automatically granted 
REM 'ADMIN' option on the role, therefore, if this script is run a second
REM time, this user will also be granted 'ADMIN' on all the roles.  You must
REM explicitly revoke 'ADMIN OPTION' from this user to prevent this from 
REM happening.
REM
REM NOTE:  This script will not capture the create or grant on the Oracle 
REM predefined roles, CONNECT, RESOURCE, DBA, EXP_FULL_DATABASE, or 
REM IMP_FULL_DATABASE. 
REM
REM Only preliminary testing of this script was performed.  Be sure to test
REM it completely before relying on it.
REM
 
set verify off
set feedback off
set termout off
set echo off
set pagesize 0
 
set termout on
select 'Creating role build script...' from dual;
set termout off
 column dbname new_value db noprint
select name dbname from v$database;

spool rep_out\&db\crt_role.sql
 
select 'CREATE ROLE ' || lower(role) || ' NOT IDENTIFIED;'
  from sys.dba_roles
  where role not in ('CONNECT','RESOURCE','DBA', 'EXP_FULL_DATABASE', 
                    'IMP_FULL_DATABASE')
  and password_required='NO'
/
select 'CREATE ROLE ' || lower(role) || ' IDENTIFIED BY VALUES ' ||
       '''' || password || '''' || ';'
  from sys.dba_roles, sys.user$
  where role not in ('CONNECT','RESOURCE','DBA', 'EXP_FULL_DATABASE',
                    'IMP_FULL_DATABASE')
  and password_required='YES' and
     dba_roles.role=user$.name
     and user$.type=0
/
 
select 'GRANT ' || lower(granted_role) || ' TO ' || lower(grantee) ||
       decode(admin_option,'YES',' WITH ADMIN OPTION;',';')
  from sys.dba_role_privs
  and granted_role not in ('CONNECT','RESOURCE','DBA', 'EXP_FULL_DATABASE',
                           'IMP_FULL_DATABASE')
  order by grantee
/
spool off
set verify on
set feedback on
set termout on
set echo on
set pagesize 22
clear columns
