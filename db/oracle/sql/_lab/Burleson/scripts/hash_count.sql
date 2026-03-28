/*  */
set long 2000 lines 132
column sql_text format a80
select sql_text,count(hash_value) hash_count from v$sqlarea
group by sql_text
order by 2 desc
/
