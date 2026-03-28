/*  */
column meas_date format a25 heading 'Measurement Date'
column name format a25 heading 'Measurement'
column value heading 'Measurement|Value'
column delta heading 'Measurement|Change'
select
   name,
   value,
   delta,
   to_char(meas_date,'dd-mon-yy hh24:mi:ss') meas_date
from
   dba_running_stats
where
   upper(name)=upper('&measurement')
   and to_char(meas_date,'dd-mon-yy hh24:mi:ss')>'&measurement_date(dd-mon-yy hh25:mi:ss)'
order by meas_date
/
