This script will calculate Oracle I/O throughput in I/O per second (IOPS):

select
   to_char(sn.end_interval_time,'yyyymmddhh24') the_date,
   sum(decode(sn2.startup_time,sn3.startup_time,(newreads.value-oldreads.value),newreads.value)) reads,
   sum(decode(sn2.startup_time,sn3.startup_time,(newwrites.value-oldwrites.value),newwrites.value)) writes,
   (sum(decode(sn2.startup_time,sn3.startup_time,(newreads.value-oldreads.value),newreads.value)))+
   (sum(decode(sn2.startup_time,sn3.startup_time,(newwrites.value-oldwrites.value),newwrites.value)))
total
from
   dba_hist_sysstat  oldreads,
   dba_hist_sysstat  newreads,
   dba_hist_sysstat  oldwrites,
   dba_hist_sysstat  newwrites,
   dba_hist_snapshot sn,
   dba_hist_snapshot sn2,
   dba_hist_snapshot sn3
where 
   sn.instance_number=dbms_utility.current_instance
and 
   sn.instance_number=sn2.instance_number
and 
   sn2.instance_number=sn3.instance_number
and 
   oldreads.instance_number=sn3.instance_number
and 
   newreads.instance_number=oldreads.instance_number
and 
   oldreads.instance_number=oldwrites.instance_number
and 
   oldwrites.instance_number=newwrites.instance_number
and 
   newreads.snap_id=sn.snap_id
and 
   newwrites.snap_id=newreads.snap_id
and 
   sn.instance_number=oldreads.instance_number
and 
   oldreads.instance_number=newreads.instance_number
and 
   sn.instance_number=oldwrites.instance_number
and 
   oldwrites.instance_number=newwrites.instance_number
and 
   oldreads.snap_id = 
   (select 
      max(sn.snap_id) 
    from 
      dba_hist_snapshot sn
    where 
      sn.snap_id<newreads.snap_id 
    and
      sn.instance_number=newreads.instance_number 
    and
      newreads.instance_number=oldreads.instance_number)
    and 
     oldreads.snap_id=sn2.snap_id
    and 
     newreads.snap_id=sn3.snap_id
    and 
     oldwrites.snap_id = (
       select 
         max(sn.snap_id) 
       from 
         dba_hist_snapshot sn
       where 
         sn.snap_id<newwrites.snap_id 
       and
         sn.instance_number=newwrites.instance_number 
       and
         newwrites.instance_number=oldwrites.instance_number)
    and 
      oldreads.stat_name = 'physical reads'
   and 
      newreads.stat_name = 'physical reads'
   and 
      oldwrites.stat_name = 'physical writes'
   and 
      newwrites.stat_name = 'physical writes'
group by 
      to_char(sn.end_interval_time,'yyyymmddhh24')
order by 
      to_char(sn.end_interval_time,'yyyymmddhh24')
;
