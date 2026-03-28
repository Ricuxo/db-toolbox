/*  */
REM
REM NAME   :log_hist.sql 
REM PURPOSE:Provide info on logs for last 24 hour since last log switch
REM USE    : From SQLPLUS
REM Limitations 	: None
REM
column thread# 		format 999 	heading 'Thrd#'
column sequence# 	format 99999 	heading 'Seq#'
column low_change# 			heading 'Low#'
column high_change# 			heading 'High#'
column first_time 		 	heading 'Accessed'
set lines 80
@title80 "Log History Report"
spool rep_out\&db\log_hist
rem
select thread#, sequence#,
   first_change#,next_change#,
   to_char(a.first_time,'dd-mon-yyyy hh24:mi:ss') time
from 
	v$log_history a 
where
 	a.first_time >
  	(select b.first_time-1
  	from v$log_history b where b.next_change# =
   	(select max(c.next_change#) from v$log_history c));
spool off
set lines 80 
clear columns 
ttitle off
pause Press enter to continue

