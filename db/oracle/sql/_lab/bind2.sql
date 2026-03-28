SELECT HASH_VALUE,sql_text FROM V$SQL
where sql_text like '&sql%'
order by 1
/
