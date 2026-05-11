SELECT TO_CHAR(s.begin_interval_time,'DY DD/MM HH24') hora,
       ROUND(SUM(CASE st.stat_name WHEN 'user commits'
                 THEN st.value_diff END),0)            commits,
       ROUND(SUM(CASE st.stat_name WHEN 'user calls'
                 THEN st.value_diff END),0)            user_calls,
       ROUND(SUM(CASE st.stat_name WHEN 'execute count'
                 THEN st.value_diff END),0)            execucoes,
       ROUND(SUM(CASE st.stat_name WHEN 'logons cumulative'
                 THEN st.value_diff END),0)            logons,
       ROUND(SUM(CASE st.stat_name WHEN 'physical reads'
                 THEN st.value_diff END),0)            physical_reads,
       ROUND(SUM(CASE st.stat_name WHEN 'redo size'
                 THEN st.value_diff END)/1024/1024,2)  redo_mb
FROM dba_hist_snapshot s
JOIN (
  SELECT snap_id, dbid, instance_number, stat_name,
         value - LAG(value) OVER (
           PARTITION BY dbid, instance_number, stat_name
           ORDER BY snap_id
         ) value_diff
  FROM dba_hist_sysstat
  WHERE stat_name IN (
    'user commits','user calls','execute count',
    'logons cumulative','physical reads','redo size'
  )
) st ON s.snap_id         = st.snap_id
     AND s.dbid            = st.dbid
     AND s.instance_number = st.instance_number
WHERE s.begin_interval_time >= SYSDATE - 7
GROUP BY TO_CHAR(s.begin_interval_time,'DY DD/MM HH24')
ORDER BY hora;