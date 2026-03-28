/*  */
select sid, name, value from v$sesstat, v$statname where
v$sesstat.statistic#=v$statname.statistic# and
v$statname.name like'%commits'
/
