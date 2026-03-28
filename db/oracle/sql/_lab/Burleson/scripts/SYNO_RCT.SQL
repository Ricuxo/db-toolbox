/*  */
REM
REM FUNCTION: SCRIPT FOR CREATING SYNONYMS
REM
REM           This script must be run by a user with the DBA role.
REM
REM           This script is intended to run with Oracle7.
REM
REM           Running this script will in turn create a script to build 
REM           all the synonyms in the database. The created script, 
REM           create_synonyms.sql, can be run by any user with the DBA 
REM           role or with the 'CREATE ANY SYNONYM' and 'CREATE PUBLIC 
REM           SYNONYM' system privileges.
REM 
REM NOTE:    This script does not capture synonyms created on tables owned 
REM          by the 'SYS' user.
REM
REM          Only preliminary testing of this script was performed.  Be 
REM          sure to test it completely before relying on it.
REM
 
set verify off
set feedback off
set termout off
set echo off
set pagesize 0 lines 132
 
set termout on
select 'Creating synonym build script...' from dual;
set termout off
column dbname new_value db noprint
select name dbname from v$database; 
define cr='chr(10)' 
spool rep_out\&db\crt_syns.sql
 
select 'CREATE '|| decode(owner,'PUBLIC','PUBLIC ',null) || 
       'SYNONYM ' || decode(owner,'PUBLIC',null, owner || '.') || 
        lower(synonym_name) || ' FOR ' || lower(table_owner) ||
        '.' || lower(table_name) || 
        decode(db_link,null,null,'@'||db_link) || ';'
  from sys.dba_synonyms
  where table_owner != 'SYS'
  order by owner
/
spool off
set verify on
set feedback on
set termout on
set echo on
set pagesize 22
clear columns
undef cr
