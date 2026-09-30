SELECT h.session_id, h.sql_id, h.sql_opname, h.sql_plan_hash_value,
       COUNT(*) * 10          seg_aprox,
       MIN(h.sample_time)     inicio,
       MAX(h.sample_time)     fim
  FROM dba_hist_active_sess_history h
 WHERE h.con_id = 4
   AND h.module = 'DBMS_SCHEDULER'
   AND h.action = 'PKG_CARGA_CAMBIO'
   AND h.sample_time BETWEEN TIMESTAMP '2026-09-29 05:25:00'
                         AND TIMESTAMP '2026-09-29 13:30:00'
 GROUP BY h.session_id, h.sql_id, h.sql_opname, h.sql_plan_hash_value
 ORDER BY inicio;

/*
SESSION_ID SQL_ID        SQL_OPNAME           SQL_PLAN_HASH_VALUE  SEG_APROX INICIO                         FIM
---------- ------------- -------------------- ------------------- ---------- ------------------------------ ------------------------------
     10538 6t8cf6agxx7wg UPSERT                        1211991860         10 29-SEP-2026 06:00:07.766       29-SEP-2026 06:00:07.766
     10538 1hd0pz79ab3wd INSERT                        4052911498      13180 29-SEP-2026 06:00:18.005       29-SEP-2026 09:45:12.213
     10538 g0wndq6u036hw SELECT                        3164676092        120 29-SEP-2026 09:45:22.453       29-SEP-2026 09:47:15.286
     10538 2mha27hca82q9 UPSERT                                 0         10 29-SEP-2026 09:47:25.525       29-SEP-2026 09:47:25.525
     10538 2mha27hca82q9 UPSERT                        3769368794      10970 29-SEP-2026 09:47:35.765       29-SEP-2026 12:54:58.965
     10538 6hsnq6u6ag3km TRUNCATE TABLE                         0         10 29-SEP-2026 12:55:09.205       29-SEP-2026 12:55:09.205
     10538 5kth4stfd9v0x INSERT                         100589311         40 29-SEP-2026 12:55:19.445       29-SEP-2026 12:55:50.229
     */