/*  */
col name format a66 heading 'Data File Name'
col count format 999,999,999 heading 'Wait Count'
col file# heading 'File#' format 9,999
col wait_time heading 'Time'
col ratio heading 'Time/Count' format 999.99
set pages 47
compute sum of count on report 
break on report
@title132 'Waits Per Datafile'
set lines 132
spool rep_out\&&db\temp_waits_file
select * from (select file#,name, count, time wait_time,time/count ratio
from x$kcbfwait, v$datafile
where indx + 1 = file#
and time>0
order by count desc)
/
spool off
clear columns
clear computes
ttitle off
set pages 22 lines 80
