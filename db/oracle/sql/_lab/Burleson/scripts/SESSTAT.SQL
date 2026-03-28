/*  */
select name,value from v$sesstat, v$statname
where v$sesstat.statistic#=v$statname.statistic# and sid=14
/
