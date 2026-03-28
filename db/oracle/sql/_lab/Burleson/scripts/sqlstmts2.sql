/*  */
set pagesize 0
set linesize 2000
SET LONG 5000
set echo off
set feedback off
COL SPOOL_FILE NEW_VALUE SPOOLIT NOPRINT
SET VERIFY OFF
SELECT 'sql_'||SUBSTR('&1',1,5) SPOOL_FILE FROM DUAL;

SPOOL &SPOOLIT

select STATEID,'^',text from STATETAB where STATEID='&1';

REM exit;
