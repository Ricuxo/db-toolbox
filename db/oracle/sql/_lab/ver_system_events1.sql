REM " Script mostra top 10 dos eventos desde do instance startup por tempo de espera"
REM " Autor - Luiz Noronha - 07/04/2010"

REM The colum 


SET heading 		ON;
set feed 		OFF;

break on WAIT_CLASS skip 1 dup

col WAIT_CLASS 		for a15
col event		for a60
col total_waits		for 999,999,999,999
col total_timeouts	for 999,999,999,999
col time_waited		for 999,999,999,999
col average_wait	for 999,999,999,999

COLUMN STARTUP_TIME HEADING '';


SELECT 'Database statup time: ' || TO_CHAR(startup_time,'DD/MM/YYYY MI:HH24:SS') STARTUP_TIME
  FROM v$instance;
 
SELECT wait_class, event, total_timeouts, total_waits, time_waited, average_wait, pct_time_waited FROM 
  (SELECT b.wait_class, a.event, a.total_timeouts, a.total_waits, a.time_waited, a.average_wait,
  	 ROUND (100*(a.time_waited / TOT_time_waited),2) pct_time_waited,
         ROW_NUMBER() OVER(PARTITION BY b.wait_class ORDER BY a.time_waited DESC) n,
         MAX(ROUND (100*(a.time_waited / TOT_time_waited),2)) OVER(PARTITION BY b.wait_class) Max_waitAGV
    FROM v$system_event a,
         v$event_name   b,
    	 (SELECT SUM(a.time_waited) TOT_time_waited
    	    FROM v$system_event a, v$event_name b
    	   WHERE a.event_id = b.event_id
    	     AND lower(b.wait_class) != 'idle'
         ) TOT_time_waited
   WHERE a.event_id = b.event_id
     AND lower(b.wait_class) != 'idle'
   ORDER BY b.wait_class, a.average_wait DESC 
  )
WHERE n <= 5
ORDER BY Max_waitAGV DESC, pct_time_waited DESC, wait_class, average_wait DESC
/
PROMPT **************************** Columns Description ****************************
PROMPT
PROMPT    TOTAL_WAITS: The number of times the sessions waited on the event
PROMPT TOTAL_TIMEOUTS: Records of the number of times a session failed to get the requested resource after the initial wait
PROMPT **Before Oracle9i Database, the unit of measure for wait event timing was in centiseconds, that is, 1/100th of a second
PROMPT Starting with Oracle9i Database, wait time has been tracked in microseconds, that is, 1/1,000,000th of a second

set feed 		ON;
CLEAR BREAKS
PROMPT 

