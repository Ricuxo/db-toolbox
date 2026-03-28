/*  */
select
(to_number(to_char(sysdate,'J'))-
 to_number(to_char(to_date('January 1, 1970, 00:00:00','month dd, YYYY, hh24:mi:ss'),'J')))*24*60*60 + 
(to_number(to_char(sysdate,'HH24'))*60*60) +
(to_number(to_char(sysdate,'MI'))*60) +
(to_number(to_char(sysdate,'SS'))) seconds_since
from dual;
