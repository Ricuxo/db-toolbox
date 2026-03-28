----SINGLE

col destination for a30 
col dest_stat for a30 
set lines 600 
select ar.inst_id "inst_id", 
ar.dest_id "dest_id", 
ar.status "dest_status", 
ar.destination "destination", 
(select MAX (sequence#) highiest_seq 
from v$archived_log val, v$database vdb 
where val.resetlogs_change# = vdb.resetlogs_change# 
and thread# = ar.inst_id 
and dest_id = ar.dest_id) 
- NVL ( 
(select MAX (sequence#) 
from v$archived_log val, v$database vdb 
where val.resetlogs_change# = vdb.resetlogs_change# 
and thread# = ar.inst_id 
and dest_id = ar.dest_id 
and standby_dest = 'YES' 
and applied = 'YES'), 
0) 
"applied_gap", 
(SELECT MAX (sequence#) highiest_seq 
from v$archived_log val, v$database vdb 
where val.resetlogs_change# = vdb.resetlogs_change# 
AND thread# = ar.inst_id) 
- NVL ( 
(SELECT MAX (sequence#) 
from v$archived_log val, v$database vdb 
where val.resetlogs_change# = vdb.resetlogs_change# 
and thread# = ar.inst_id 
and dest_id = ar.dest_id 
and standby_dest = 'YES'), 
0) 
"received_gap", 
NVL ( 
(SELECT MAX (sequence#) 
from v$archived_log val, v$database vdb 
where val.resetlogs_change# = vdb.resetlogs_change# 
and thread# = ar.inst_id 
and dest_id = ar.dest_id 
and standby_dest = 'YES'), 
0) 
"last_received_seq", 
NVL ( 
(SELECT MAX (sequence#) 
from v$archived_log val, v$database vdb 
where val.resetlogs_change# = vdb.resetlogs_change# 
and thread# = ar.inst_id 
and dest_id = ar.dest_id 
and standby_dest = 'YES' 
and applied = 'YES'), 
0) 
"last_applied_seq" 
from (SELECT DISTINCT dest_id, 
inst_id, 
status, 
target, 
destination, 
error 
from sys.gv_$archive_dest 
where target = 'STANDBY' and STATUS <> 'DEFERRED') ar 
order by dest_id;




----RAC


------ORACLE RAC
set linesize 120
col PRIMARY_TIME format a20
col STANDBY_COMPLETION_TIME format a23
SELECT
prim.thread# thread,
prim.seq primary_seq,
to_char(prim.tm, 'DD-MON-YYYY HH24:MI:SS') primary_time,
tgt.thread# standby_thread,
tgt.seq standby_seq,
to_char(tgt.tm, 'DD-MON-YYYY HH24:MI:SS') standby_completion_time,
prim.seq-tgt.seq seq_gap,
( prim.tm-tgt.tm ) * 24 * 60 lag_minutes
FROM
(
SELECT
thread#,
MAX(sequence#) seq,
MAX(completion_time) tm
FROM
v$archived_log
GROUP BY
thread#
) prim,
(
SELECT
thread#,
MAX(sequence#) seq,
MAX(completion_time) tm
FROM
v$archived_log
WHERE
dest_id IN (
SELECT
dest_id
FROM
v$archive_dest
WHERE
target = 'STANDBY'
)
AND applied = 'YES'
GROUP BY
thread#
) tgt
WHERE
prim.thread# = tgt.thread#;
