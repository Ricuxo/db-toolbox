break on report
col username format a20
compute sum of soma on report
select username,count(1) soma from v$session where status='ACTIVE' 
and username is not null
group by username order by 2
/
