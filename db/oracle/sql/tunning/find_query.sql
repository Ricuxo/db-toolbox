---query rodando
select last_active_time lasexec, a.*  from v$sql a where sql_fulltext  LIKE '%Registros Ativos na base de SPC.%' 
and upper(sql_fulltext) not like upper('%Analyze%')
and upper(sql_fulltext) not like upper('%SQLTEXT%')
and upper(sql_fulltext)  like ('%2019-02-24%')
and upper(sql_fulltext) not like upper('%V$%') order by last_active_time desc; 

---query que rodou
select * from v$sql where sql_id='5cc2wyd2wbu8t';
select last_active_time lasexec, a.*  from v$sql a where sql_fulltext  LIKE '%Registros Ativos na base de SPC.%' 
and upper(sql_fulltext) not like upper('%Analyze%')
and upper(sql_fulltext) not like upper('%SQLTEXT%')
--and upper(sql_fulltext)  like ('%2019-02-24%')
and upper(sql_fulltext) not like upper('%V$%') order by last_active_time desc; 
só comentei a linha ('%2019-02-24%') 