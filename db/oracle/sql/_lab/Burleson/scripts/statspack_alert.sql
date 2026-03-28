/*  */
--*********************************************************** 
-- 
-- STATSPACK alert report for the DBA 
-- 
-- Created 8/4/2000 by Donald K. Burleson 
-- www.dba-oracle.com 
-- 
-- This script is provided free-of-charge by Don Burleson 
-- and no portion of this script may be sold to anyone for any reason! 
-- 
-- This script accepts the "number of days back" as an imput parameter 
-- 
-- This script can be scheduled to run daily via cron or OEM 
-- and e-mail the results to the on-call DBA 
-- 
--*********************************************************** 
set pages 9999; 
set feedback off; 
set verify off; 
--*********************************************************** 
-- Alert when data buffer hit ratio is below threshold 
--*********************************************************** 
prompt 
prompt 
prompt *********************************************************** 
prompt When the data buffer hit ratio falls below 90%, you 
prompt should consider adding to the db_block_buffer init.ora parameter 
prompt 
prompt See p. 171 "High Performance Oracle8 Tuning" by Don Burleson 
prompt 
prompt *********************************************************** 
prompt 
prompt 
column logical_reads format 999,999,999 
column phys_reads format 999,999,999 
column phys_writes format 999,999,999 
column "BUFFER HIT RATIO" format 999 
select to_char(snap_time,'yyyy-mm-dd HH24'), 
-- 
a.value + b.value "logical_reads", 
-- 
c.value "phys_reads", 
-- 
d.value "phys_writes", 
round(100 * ((a.value+b.value)-c.value) / (a.value+b.value)) "BUFFER HIT RATIO" 
from perfstat.stats$sysstat a, perfstat.stats$sysstat b, 
perfstat.stats$sysstat c, perfstat.stats$sysstat d, 
perfstat.stats$snapshot sn 
where (round(100 * ((a.value+b.value)-c.value) / (a.value+b.value)) ) < 90 
and snap_time > sysdate-&1 
and a.snap_id = sn.snap_id 
and b.snap_id = sn.snap_id 
and c.snap_id = sn.snap_id 
and d.snap_id = sn.snap_id 
and a.statistic# = 39 
and b.statistic# = 38 
and c.statistic# = 40 
and d.statistic# = 41 ; 
--*********************************************************** 
-- Alert when total disk sorts are below threshold 
--*********************************************************** 
prompt 
prompt 
prompt *********************************************************** 
prompt When there are high disk sorts, you should investigate 
prompt increasing sort_area_size, or adding indexes to force index_full scans 
prompt 
prompt See p. 167 "High Performance Oracle8 Tuning" by Don Burleson 
prompt 
prompt *********************************************************** 
prompt 
prompt 
column sorts_memory format 999,999,999 
column sorts_disk format 999,999,999 
column ratio format .99999 
select to_char(snap_time,'yyyy-mm-dd HH24'), a.value sorts_memory, 
b.value sorts_disk, (b.value/a.value) ratio 
from perfstat.stats$sysstat a, perfstat.stats$sysstat b, 
perfstat.stats$snapshot sn 
where 
-- Where there are more than 200 disk sorts per hour 
b.value > 200 and snap_time > sysdate-&1 
and a.snap_id = sn.snap_id 
and b.snap_id = sn.snap_id 
and a.name = 'sorts (memory)' 
and b.name = 'sorts (disk)' ; 
--*********************************************************** 
-- Alert when total I/O wait count is above threshold
--*********************************************************** 
prompt 
prompt 
prompt *********************************************************** 
prompt When there is high I/O waits, disk bottlenecks may exist 
prompt Run iostats to find the hot disk and shuffle files to 
prompt remove the contention 
prompt 
prompt See p. 191 "High Performance Oracle8 Tuning" by Don Burleson 
prompt 
prompt *********************************************************** 
prompt 
prompt 
break on snapdate skip 2 
column snapdate format a16 
column filename format a40 
select to_char(snap_time,'yyyy-mm-dd HH24') snapdate, filename, wait_count 
from perfstat.stats$filestatxs fs, perfstat.stats$snapshot sn 
where snap_time > sysdate-&1 and fs.snap_id = sn.snap_id and wait_count > 800 ; 
--*********************************************************** 
-- Alert when average buffer busy waits exceed threshold 
--*********************************************************** 
prompt 
prompt 
prompt *********************************************************** 
prompt Buffer Bury Waits may signal a high update table with too 
prompt few freelists. Find the offending table and add more freelists. 
prompt 
prompt See p. 134 "Oracle SAP Administration" by Don Burleson 
prompt 
prompt *********************************************************** 
prompt 
prompt 
column buffer_busy_wait format 999,999,999 
select to_char(snap_time,'yyyy-mm-dd HH24'), avg(buffer_busy_wait) buffer_busy_wait 
from perfstat.stats$buffer_pool_statistics fs, perfstat.stats$snapshot sn 
where snap_time > sysdate-&1 and fs.snap_id = sn.snap_id having avg(buffer_busy_wait) > 100 
group by to_char(snap_time,'yyyy-mm-dd HH24') ; 
--*********************************************************** 
-- Alert when total redo log space requests exceed threshold 
--*********************************************************** 
prompt 
prompt 
prompt *********************************************************** 
prompt High redo log space requests indicate a need to increase 
prompt the log_buffer parameter 
prompt 
prompt 
prompt *********************************************************** 
prompt 
prompt 
column redo_log_space_requests format 999,999,999 
select to_char(snap_time,'yyyy-mm-dd HH24') snap_date, a.value redo_log_space_requests 
from perfstat.stats$sysstat a, perfstat.stats$snapshot sn 
where snap_time > sysdate-&1 and a.value > 300 
and a.snap_id = sn.snap_id 
and a.name = 'redo log space requests' ; 
--*********************************************************** 
-- Alert when table_fetch_continued_row exceeds threshold 
--*********************************************************** 
prompt 
prompt 
prompt *********************************************************** 
prompt Table fetch continued row indicates chained rows, or fetches of 
prompt long datatypes (long raw, blob) 
prompt 
prompt Investigate increasing db_block_size or reorganizing tables 
prompt with chained rows. 
prompt 
prompt See p. 381 "High Performance Oracle8 Tuning" by Don Burleson 
prompt See p. 102 "Oracle SAP Administration" by Don Burleson 
prompt 
prompt *********************************************************** 
prompt 
prompt 
column table_fetch_continued_row format 999,999,999 
select to_char(snap_time,'yyyy-mm-dd HH24'), avg(a.value) table_fetch_continued_row 
from perfstat.stats$sysstat a, perfstat.stats$snapshot sn 
where snap_time > sysdate-&1 
and a.snap_id = sn.snap_id 
and a.name = 'table fetch continued row' 
having avg(a.value) > 100000 group by to_char(snap_time,'yyyy-mm-dd HH24') ;

