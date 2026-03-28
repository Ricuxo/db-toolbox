/*  */
set feedback off verify off echo off
connect &1
column xdb_name new_value xdb noprint
select name xdb_name from v$database;
set sqlprompt '&xdb>'
set feedback on verify on
clear columns

