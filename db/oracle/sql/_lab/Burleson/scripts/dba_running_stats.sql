/*  */
create table dba_running_stats (
NAME 		VARCHAR2(64),
VALUE 		NUMBER,
REP_ORDER 	NUMBER,
MEAS_DATE 	DATE,
DELTA 		NUMBER)
storage(initial 1m next 1m pctincrease 0)

/
