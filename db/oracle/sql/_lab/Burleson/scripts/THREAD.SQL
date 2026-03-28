/*  */
rem
rem FUNCTION: Provide data on Redo Log Threads
rem
rem name:     thread.sql 
rem
column current_group#       heading Current|Group#
column Checkpoint_change#   heading Checkpoint|Change#
column checkpoint_time      heading Checkpoint|Time
column open_time            heading Open|Time
column thread#              heading Thread#
column status               heading Status
column enabled              heading Enabled
column groups               heading Groups
column Instance             heading Instance
column sequence#            heading Sequence#
set lines 132 pages 59
start title132 'Redo Thread Report'
spool rep_out\&db\theads
select * from sys.v_$thread
order by thread#;
spool off
pause Press enter to continue
set lines 80 pages 22
ttitle off
clear columns

