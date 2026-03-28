col sql_text format a100
set linesize 200
set pagesize 10000
SELECT substr(sql_text,1,100) sql_text,count(1) FROM V$SQL
group by  substr(sql_text,1,100)
having count(1)> 70
order by 2
/
