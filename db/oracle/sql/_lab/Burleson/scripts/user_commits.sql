/*  */
column name format a30
set pages 57
select sid,name,value from v$sesstat, v$statname
where name like '%commits%' and
v$sesstat.statistic#=v$statname.statistic#
/
