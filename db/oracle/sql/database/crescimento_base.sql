--Crescimento mensal banco de dados (ano atual)
select to_char(creation_time, 'MM-RRRR') "Month", sum(bytes)/1024/1024/1024 "Growth in GB"
from sys.v_$datafile
where to_char(creation_time,'RRRR')='2020'
group by to_char(creation_time, 'MM-RRRR')
order by  to_char(creation_time, 'MM-RRRR');

--Crescimento mensal banco de dados (todos os anos)

col GBytes for 999999999
col ANO for a15
col MES for a15
select to_char(CREATION_TIME,'RRRR') ANO, to_char(CREATION_TIME,'MM') MES, sum(bytes/1024/1024/1024) GBytes 
from v$datafile 
group by 
   to_char(CREATION_TIME,'RRRR'), 
   to_char(CREATION_TIME,'MM') 
order by 1, 2;