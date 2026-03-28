/*  */
column garbage format a14 heading 'Non-Shared SQL'
column good format a14 heading 'Shared SQL'
column good_percent format a14 heading 'Percent Shared'
column users format a14 heading users
column nopr noprint
set feedback off 
ttitle 'Shared Pool Utilization'
spool sql_garbage
select 1 nopr,
a.users users, 
to_char(a.garbage,'9,999,999,999') garbage,
to_char(b.good,'9,999,999,999') good,
to_char((b.good/(b.good+a.garbage))*100,'9,999,999.999') good_percent
from sql_garbage a, sql_garbage b
where a.users=b.users
and a.garbage is not null and b.good is not null
union
select 2 nopr,
'-------------' users,'--------------' garbage,'--------------' good,
'--------------' good_percent from dual
union
select 3 nopr,
to_char(count(a.users)) users,
to_char(sum(a.garbage),'9,999,999,999') garbage,
to_char(sum(b.good),'9,999,999,999') good,
to_char(((sum(b.good)/(sum(b.good)+sum(a.garbage)))*100),'9,999,999.999') good_percent
from sql_garbage a, sql_garbage b
where a.users=b.users
and a.garbage is not null and b.good is not null
order by 1,3 desc
/
spool off
ttitle off
