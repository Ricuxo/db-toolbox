SELECT s.snap_id, sn.begin_interval_time, s.plan_hash_value, s.sql_profile
FROM   dba_hist_sqlstat s
JOIN   dba_hist_snapshot sn ON sn.snap_id = s.snap_id AND sn.dbid = s.dbid
WHERE  s.sql_id = '2dxyfk5cwpg5x'
ORDER BY s.snap_id DESC
FETCH FIRST 10 ROWS ONLY;