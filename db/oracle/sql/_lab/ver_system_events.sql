REM " Script mostra top 10 dos eventos desde do instance startup por tempo de espera"
REM " Autor - Luiz Noronha - 07/04/2010"

REM The colum 

break on WAIT_CLASS skip 1 dup
SET heading 		ON;
SET PAGESIZE 		100

col WAIT_CLASS 		for a15
col event		for a65
col total_waits		for 999,999,999,999
col total_timeouts	for 999,999,999
col time_waited		for 999,999,999,999
col average_wait	for 999,999,999,999

COLUMN STARTUP_TIME HEADING '';


SELECT 'Database statup time: ' || TO_CHAR(startup_time,'DD/MM/YYYY HH24:MI:SS') STARTUP_TIME
  FROM v$instance;
 
SELECT wait_class, event, total_timeouts, total_waits, time_waited, average_wait FROM 
  (SELECT b.wait_class, a.event, a.total_timeouts, a.total_waits, a.time_waited, a.average_wait,
         ROW_NUMBER() OVER(PARTITION BY b.wait_class ORDER BY a.average_wait DESC) n,
         MAX(A.average_wait) OVER(PARTITION BY b.wait_class) Max_waitAGV
    FROM v$system_event a,
         v$event_name   b
   WHERE a.event_id = b.event_id
   ORDER BY b.wait_class, a.average_wait DESC )
WHERE n <= 5
ORDER BY Max_waitAGV DESC, wait_class, average_wait DESC
/
