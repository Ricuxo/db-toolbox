/*  */
COLUMN log_id FORMAT 999999
COLUMN filename FORMAT A20
COLUMN low_scn  FORMAT 9999999
COLUMN high_scn FORMAT 9999999
SET LINES 132 PAGES 45
@title132 'Log Miner Log Files'
SPOOL rep_out\&&db\log_miner
SELECT     
   db_id,
   log_id,filename,
   to_char(low_time,'dd-mon-yy hh:mi:ss') low_time,
   to_char(high_time,'dd-mon-yy hh:mi:ss') high_time,
   low_scn,next_scn
FROM 
   v$logmnr_logs
ORDER BY 
   Low_time
/
SPOOL OFF
SET LINES 80 PAGES 22
