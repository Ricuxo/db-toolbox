SET lines 200 pages 1000
COL begin_interval_time FOR A30

SELECT HIST_SNAPSHOT.snap_id,
       HIST_SNAPSHOT.begin_interval_time,
       HIST_RESOURCE_LIMIT.current_utilization,   
       HIST_RESOURCE_LIMIT.max_utilization,
       HIST_RESOURCE_LIMIT.initial_allocation
FROM DBA_HIST_RESOURCE_LIMIT HIST_RESOURCE_LIMIT,
      SYS.DBA_HIST_SNAPSHOT   HIST_SNAPSHOT
WHERE HIST_RESOURCE_LIMIT.resource_name='processes'
  AND HIST_RESOURCE_LIMIT.snap_id=HIST_SNAPSHOT.snap_id
ORDER BY HIST_SNAPSHOT.snap_id DESC;