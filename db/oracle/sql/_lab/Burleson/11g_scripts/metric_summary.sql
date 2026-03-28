/*  */
select
  metric_name “Metric Name”,
  metric_unit "Metric Unit",
  minval "Minimum Value",
  maxval "Maximum Value",
  average "Average Value"
from
  DBA_HIST_SYSMETRIC_SUMMARY
where
       snap_id           = &pEndSnap
   and dbid              = &pDbId
   and instance_number   = &pInstNum
