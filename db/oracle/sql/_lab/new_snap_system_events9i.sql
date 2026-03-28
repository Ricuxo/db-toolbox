CREATE OR REPLACE PROCEDURE p_snapshot_prep_sys_events
AS 
BEGIN
INSERT INTO system.prepay_system_events_snap
  SELECT a.event, 
  	 a.total_timeouts, 
  	 a.total_waits,
  	 a.time_waited, 
  	 a.average_wait,
	 ROUND (100*(a.time_waited/ TOT_time_waited),2) pct_time_waited,
  	 (SELECT  max(snap_id) + 1 FROM system.prepay_system_events_snap), sysdate snap_time
    FROM v$system_event a,
    	 (SELECT SUM(a.time_waited)  TOT_time_waited
    	    FROM v$system_event a
         ) TOT_time_waited
   ORDER BY pct_time_waited;
END;