COMPUTE SUM LABEL 'TOTAL' OF qtde ON REPORT
BREAK ON REPORT

select s.inst_id, x.qcsid,s.username,count(*) qtde
from gv$px_session x,gv$session s
where x.qcsid=s.sid
and x.inst_id=s.inst_id
group by s.inst_id,x.qcsid,s.username;
