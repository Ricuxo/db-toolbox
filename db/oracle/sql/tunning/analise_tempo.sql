select s.end_interval_time ,
       'buffer busy waits', BUFFER_BUSY_WAITS_DELTA 
  from DBA_HIST_SEG_STAT p, dba_hist_snapshot s
where p.snap_id = s.snap_id
   and p.instance_number = s.instance_number
   and trunc(s.begin_interval_time) >= to_date(:begindate_yyymmdd,'yyyymmdd')
   and OBJ# = :objid
   and p.instance_number= :inst_id
union
select s.end_interval_time ,
       'row lock waits', ROW_LOCK_WAITS_DELTA
  from DBA_HIST_SEG_STAT p, dba_hist_snapshot s
where p.snap_id = s.snap_id
   and p.instance_number = s.instance_number
   and trunc(s.begin_interval_time) >= to_date(:begindate_yyymmdd,'yyyymmdd')
   and OBJ# = :objid
   and p.instance_number= :inst_id
order by 1
