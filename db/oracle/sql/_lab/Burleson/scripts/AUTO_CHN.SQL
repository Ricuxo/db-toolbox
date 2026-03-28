/*  */
rem  **************************************************************************
rem
rem  NAME: AUTO_CHN.sql     
rem
rem  FUNCTION: Run CHAINING.sql for all of a specified users tables. 
rem
rem  NOTES:    Requires a minor mod to CHAINING.sql. See CHAINING.sql header.
rem
rem  INPUTS:
rem            tabown = Name of owner.
rem
rem  **************************************************************************

accept tabown prompt 'Enter table owner: '

set termout off feedback off verify off echo off heading off pages 999 
set embedded on
column value new_value db noprint
select value from v$parameter where name='db_name';
spool rep_out\auto_chn.gql

select 'start chaining &tabown '||table_name
  from dba_tables
 where owner = upper('&tabown')
/

spool off
spool rep_out\&db\chaining 
start rep_out\auto_chn.gql
spool off 
undef tabown
set termout on feedback 15 verify on pagesize 20 linesize 80 space 1
set embedded off
ho del rep_out\auto_chn.gql
pause Press enter to continue

 
