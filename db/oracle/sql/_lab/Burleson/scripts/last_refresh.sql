/*  */
column name heading "Snapshot Name"
column last_refresh format a20 heading "Last Refresh|Date"
column next format a25
set lines 130
select name,to_char(last_refresh,'dd-mon-yyyy hh24:mi:ss') last_refresh, 
can_use_log, error, next
 from dba_snapshots
order by name
/
