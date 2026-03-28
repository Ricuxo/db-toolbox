/*  */
set lines 140 pages 55 verify off feedback off
col num_of_times heading 'Number|Of|Repeats'
col SQL heading 'SubString - &&chars Characters' 
col username format a15 heading 'User'
@title132 'Similar SQL'
spool rep_out\&db\similar_sql&&chars
select b.username,substr(a.sql_text,1,&&chars) SQL, count(a.sql_text) num_of_times from v$sqlarea a, dba_users b
where a.parsing_user_id=b.user_id
group by b.username,substr(a.sql_text,1,&&chars) having count(a.sql_text)>&&num_repeats
order by count(a.sql_text) desc
/
spool off
undef chars
undef num_repeats
clear columns
set lines 80 pages 22 verify on feedback on
ttitle off

