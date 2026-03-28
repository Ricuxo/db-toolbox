select 
status || ': ' || trim(decode(status,'-------------------','',to_char(n,'999,999'))) "Conexões", decode(Inst_id,0,'',inst_id) "Instancia"
from
(
select 0, count(*) n, 'total' status,0 inst_id
from gv$session
union
select 1,1 n,'-------------------' status,0 inst_id from dual
union
select 2,count(*) n, status, inst_id
from gv$session
group by status, inst_id
order by 1, 2
);