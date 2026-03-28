/*  */
REM
REM part_tab_rct.sql
REM
REM FUNCTION: SCRIPT FOR CREATING PARTITIONED TABLES
REM
REM           This script can be run by any user .
REM
REM           This script is intended to run with Oracle8i.
REM
REM           Running this script will in turn create a script to 
REM           build all the partitioned tables owned by the user in the database.  
REM           This created script, create_part_table.sql, can be run by any user 
REM           with the 'CREATE TABLE' system privilege. 
REM
REM NOTE:     The script will NOT include constraints on tables.  This 
REM           script will also NOT capture tables created by user 'SYS'.
REM
REM Only preliminary testing of this script was performed.  Be sure to test
REM it completely before relying on it.
REM
 
set verify off
rem set feedback off
rem set echo off;
set pagesize 0 lines 132 embedded on
 
set termout on
select 'Creating table build script...' from dual;
rem set termout off
 
truncate table t_temp;
drop sequence lineno_seq;
create sequence lineno_seq start with 1 increment by 1 nocache nocycle;

 
set heading off trimspool on
execute recreate_table
spool create_part_table.sql
 
select   text
from     T_temp
order by  tb_name, lineno;
 
spool off
 
drop table t_temp;
set verify on
set feedback on
set termout on
set pagesize 22 lines 80


