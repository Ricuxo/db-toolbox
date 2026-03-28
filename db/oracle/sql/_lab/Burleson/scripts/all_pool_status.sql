/*  */
start title80 'All Buffer Pool Status'
spool rep_out\&&db\all_pool_status
select
count(*) COUNT,
kcbwbpd.bp_name,
decode(state,0,'FREE - Not Currently Used',1, decode(lrba_seq,0,'XCUR:FRBL - Exclusive: Freeable','XCUR:RECR - Exclusive:Recreatable'),
  2,'SCUR - Shared Current',
  3,'CR - Consistent Read: Recreatable',
  4,'READ - Being Read from Disk',
  5,'MREC - Media Recover',
  6,'IREC - Instance Recovery') STATE
from sys.x$bh bh, sys.x$kcbwbpd kcbwbpd, sys.x$kcbwds kcbwds
where kcbwds.set_id >= kcbwbpd.bp_lo_sid
and kcbwds.set_id <= kcbwbpd.bp_hi_sid
and kcbwbpd.bp_size != 0
and bh.set_ds=kcbwds.addr
group by kcbwbpd.bp_name, decode(state,0,'FREE - Not Currently Used',1, decode(lrba_seq,0,'XCUR:FRBL - Exclusive: Freeable','XCUR:RECR - Exclusive:Recreatable'),
  2,'SCUR - Shared Current',
  3,'CR - Consistent Read: Recreatable',
  4,'READ - Being Read from Disk',
  5,'MREC - Media Recover',
  6,'IREC - Instance Recovery')
order by 1 desc
/
spool off
