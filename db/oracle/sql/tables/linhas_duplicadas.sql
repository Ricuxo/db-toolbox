---ORA-01452: Cannot Create Unique Index; Duplicate Keys Found (Doc ID 332494.1)
REM This is an example SQL*Plus Script to detect duplicate rows from
REM a table.
REM
set echo off
set verify off heading off
undefine t
undefine c
prompt
prompt
prompt Enter name of table with duplicate rows
prompt
accept t prompt 'Table: '
prompt
select 'Table '||upper('&&t') from dual;
describe &&t
prompt
prompt Enter name(s) of column(s) which should be unique. If more than
prompt one column is specified, you MUST separate with commas.
prompt
accept c prompt 'Column(s): '
prompt
select &&c from &&t
where  rowid not in (select min(rowid) from &&t group by &&c)
/