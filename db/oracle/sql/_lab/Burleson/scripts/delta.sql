/*  */
update dba_running_stats set delta=
(select a.value-b.value from
dba_running_stats a, dba_running_stats b where
a.name=b.name and
b.meas_date between a.meas_date-35/1440 and a.meas_date-25/1440)
where meas_date is not null
/
