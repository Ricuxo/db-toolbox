/*  */
drop table dba_running_stats;
create table dba_running_stats (
NAME VARCHAR2(64),
VALUE NUMBER,
REP_ORDER NUMBER,
MEAS_DATE DATE,
delta number)
storage(initial 1m next 1m pctincrease 0)
tablespace &&data_tablespace
/
