col event format a50;
select decode(event,'db file scattered read',event || ' - **** FULL TABLE SCAN ****',EVENT) Event, count(1) as Qtde
from gv$session_wait
group by event
order by 2 desc;