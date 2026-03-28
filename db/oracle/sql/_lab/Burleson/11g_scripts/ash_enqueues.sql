

column begin_interval_time format a10
column req_reason          format a25
column cum_wait_time       head CUM|WAIT|TIME
column total_req#          head TOTAL|REQ#
column total_wait#         head TOTAL|WAIT#
column failed_req#         head FAILED|REQ#

select
   begin_interval_time,
   eq_type,
   req_reason,
   total_req#,
   total_wait#,
   succ_req#,
   failed_req#,
   cum_wait_time
from
   dba_hist_enqueue_stat
 natural join
   dba_hist_snapshot
where
   cum_wait_time > 0
order by
    begin_interval_time,
    cum_wait_time
;
