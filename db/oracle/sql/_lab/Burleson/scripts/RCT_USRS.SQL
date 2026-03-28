/*  */
REM rct_usrs.sql
REM
REM FUNCTION: Create a script to recreate users
REM
REM This script is designed to run on an ORACLE database
REM
REM This script creates a script called crt_usrs.sql that 
REM recreates the CREATE USER commands required to rebuild the database
REM user community. The script includes the tablespace quota grants for REM each user as a set of ALTER USER commands. The user’s passwords are
REM initially set to the username so editing is suggested if other 
REM values are desired.
REM
REM Only preliminary testing has been accomplished on this script, 
REM please fully qualify it for your environment before use
REM
REM M. Ault Burleson Consulting 8.23.01
REM
set verify off feedback off termout off echo off pagesize 0 embedded on
set heading off
set termout on
prompt Creating user create script...
set termout off
rem
rem FUNCTION: Create a use recreate script
rem
column dbname new_value db noprint
select name dbname from v$database;
define cr='chr(10)'
spool rep_out\&db\crt_usrs.sql

SELECT 'create user '||username||' identified by values '||chr(39)||password||chr(39)||&&cr||
' default tablespace '||default_tablespace||&&cr||
' temporary tablespace '||temporary_tablespace||&&cr||
' profile '||profile||&&cr||
' quota unlimited on '||default_tablespace||';'||&&cr x
FROM dba_users
WHERE username not in ('SYS','SYSTEM')
UNION
SELECT 'alter user '||username||&&cr||
'quota '||bytes||' on '||tablespace_name||';'||&&cr x
FROM dba_ts_quotas
WHERE username not in ('SYS','SYSTEM')
order by x desc
/
spool off
set verify on feedback on termout on pagesize 22 embedded off
set heading on
clear columns
undef cr
