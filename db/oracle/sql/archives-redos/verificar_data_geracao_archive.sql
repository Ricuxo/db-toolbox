--Verificar data da geração de um archive
select sequence#,FIRST_CHANGE#, substr(name,1,96),creator, to_char(first_time,'DD-MON HH24:MI'), to_char(completion_time,'DD-MON HH24:MI')
from v$archived_log
where first_time > sysdate-5
--and SEQUENCE#=235788
order by 1;
