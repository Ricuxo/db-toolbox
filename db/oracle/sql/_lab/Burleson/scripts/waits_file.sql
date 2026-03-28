/*  */
col name format a50 heading 'Data File Name'
col count format 999,999,999 heading 'Wait|Count'
col file# heading 'File#' format 9,999
col wait_time heading 'Time'
col ratio heading 'Time|Count' format 999.99
set pages 47
compute sum of count on report 
break on report
@title80 'Waits Per Datafile'
spool rep_out\&db\waits_file
set lines 132
spool waits_file.lst
SELECT file#, name, count, time wait_time,
time/count ratio
FROM x$kcbfwait, v$datafile
WHERE indx + 1 = file#
AND time>0
Order By count DESC
/
spool off
clear columns
clear computes
ttitle off
set pages 22 lines 80
