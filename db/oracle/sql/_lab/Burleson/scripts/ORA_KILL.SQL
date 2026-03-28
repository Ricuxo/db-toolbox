/*  */
REM
REM ORA_KILL.SQL
REM FUNCTION	: Kills non-essential Oracle sessions (those that aren't owned
REM			: by SYS or "NULL" 
REM DEPENDANCIES: Depends on kill_session procedure
REM MRA 9/12/96
REM
set heading off termout off verify off echo off
spool kill_all.sql
select 'execute kill_session('||chr(39)||sid||chr(39)||','||
chr(39)||serial#||chr(39)||');' from v$session
where username is not null
or username <> 'SYS'
/
spool off
rem start kill_all.sql

