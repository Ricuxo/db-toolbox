/*  */
col meas_date format a15
@title80 'Pool Track'
spool rep_out\&db\pool_track
select
to_char(meas_date,'dd-mon-yy hh24:mi') meas_date,
sp_used,
sp_avail,
full_pct
from pool_track
where meas_date > '&rep_date'
/
spool off
