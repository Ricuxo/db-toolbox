set termout off
--col spoolref new_value spoolref noprint
--select '/tmp/sqlplus_settings'||abs(dbms_random.random) spoolref from dual;
--STORE SET &spoolref REPLACE
set termout on

set long 999999999
set lines 150
set pages 500
set verify off

col sql_fulltext for a90 word_wrapped

select rows_processed,sql_fulltext,buffer_gets,disk_reads,executions from gv$sqlstats where sql_id='&1' and rownum=1;

clear columns

--@spoolref
set termout on
--host rm &spoolref..sql
undefine spoolref