set linesize 135
set head off
set pagesize 0
select sql_text from v$sqltext where address='&addr'
order by piece
/
