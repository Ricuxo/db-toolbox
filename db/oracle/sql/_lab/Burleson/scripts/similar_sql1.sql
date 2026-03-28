/*  */
set lines 132 pages 55
col num_of_times heading 'Number|Of|Repeats'
col substr(a.sql_text,1,110) heading 'SubString - 90 Characters' 
col username format a10 heading 'User'
@title132 'Similar SQL'
spool rep_out\&db\similar_sql
select substr(a.sql_text,1,110), count(a.sql_text) num_of_times from v$sqlarea a
group by substr(a.sql_text,1,110) having count(a.sql_text)>3
order by 2 desc
/
spool off
