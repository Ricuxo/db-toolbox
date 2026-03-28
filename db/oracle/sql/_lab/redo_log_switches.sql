-- Redo Log File Switches – By hour of the day

prompt
prompt "Morning .........."
select to_char(first_time,'DD/MON') day,
to_char(sum(decode(to_char(first_time,'HH24'),'07',1,0)),'000')"07",
to_char(sum(decode(to_char(first_time,'HH24'),'08',1,0)),'000')"08",
to_char(sum(decode(to_char(first_time,'HH24'),'09',1,0)),'000')"09",
to_char(sum(decode(to_char(first_time,'HH24'),'10',1,0)),'000')"10",
to_char(sum(decode(to_char(first_time,'HH24'),'11',1,0)),'000')"11",
to_char(sum(decode(to_char(first_time,'HH24'),'12',1,0)),'000')"12",
to_char(sum(decode(to_char(first_time,'HH24'),'13',1,0)),'000')"13",
to_char(sum(decode(to_char(first_time,'HH24'),'14',1,0)),'000')"14",
to_char(sum(decode(to_char(first_time,'HH24'),'15',1,0)),'000')"15",
to_char(sum(decode(to_char(first_time,'HH24'),'16',1,0)),'000')"16",
to_char(sum(decode(to_char(first_time,'HH24'),'17',1,0)),'000')"17",
to_char(sum(decode(to_char(first_time,'HH24'),'18',1,0)),'000')"18"
from v$log_history
WHERE TRUNC(FIRST_TIME) > TRUNC(SYSDATE) - 7
group by to_char(first_time,'DD/MON');
prompt
prompt
Prompt "Evening ........"
prompt
select to_char(first_time,'DD/MON') day,
to_char(sum(decode(to_char(first_time,'HH24'),'19',1,0)),'000')"19",
to_char(sum(decode(to_char(first_time,'HH24'),'20',1,0)),'000')"20",
to_char(sum(decode(to_char(first_time,'HH24'),'21',1,0)),'000')"21",
to_char(sum(decode(to_char(first_time,'HH24'),'22',1,0)),'000')"22",
to_char(sum(decode(to_char(first_time,'HH24'),'23',1,0)),'000')"23",
to_char(sum(decode(to_char(first_time,'HH24'),'00',1,0)),'000') "00",
to_char(sum(decode(to_char(first_time,'HH24'),'01',1,0)),'000')"01",
to_char(sum(decode(to_char(first_time,'HH24'),'02',1,0)),'000')"02",
to_char(sum(decode(to_char(first_time,'HH24'),'03',1,0)),'000')"03",
to_char(sum(decode(to_char(first_time,'HH24'),'04',1,0)),'000')"04",
to_char(sum(decode(to_char(first_time,'HH24'),'05',1,0)),'000')"05",
to_char(sum(decode(to_char(first_time,'HH24'),'06',1,0)),'000')"06"
from v$log_history
WHERE TRUNC(FIRST_TIME) > TRUNC(SYSDATE) - 7
group by to_char(first_time,'DD/MON');
