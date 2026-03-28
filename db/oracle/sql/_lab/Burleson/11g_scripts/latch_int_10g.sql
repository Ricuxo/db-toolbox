/*  */
select e.latch_name "Latch Name"
     , e.gets    - b.gets  "Get Requests"
     , to_number(decode(e.gets, b.gets, null,
       (e.misses - b.misses) * 100/(e.gets - b.gets)))   "Percent Get Misses"
     , to_number(decode(e.misses, b.misses, null,
       (e.sleeps - b.sleeps)/(e.misses - b.misses)))     "Avg Sleeps / Miss"
     , (e.wait_time - b.wait_time)/1000000 "Wait Time (s)"
     , e.immediate_gets - b.immediate_gets "No Wait Requests"
     , to_number(decode(e.immediate_gets,
			b.immediate_gets, null,
                     (e.immediate_misses - b.immediate_misses) * 100 /
	                (e.immediate_gets   - b.immediate_gets)))     "Percent No Wait Miss"
 from  dba_hist_latch  b
     , dba_hist_latch  e
 where b.snap_id         = &pBgnSnap
   and e.snap_id         = &pEndSnap
   and b.dbid            = &pDbId
   and e.dbid            = &pDbId
   and b.dbid            = e.dbid
   and b.instance_number = &pInstNum
   and e.instance_number = &pInstNum
   and b.instance_number = e.instance_number
   and b.latch_hash      = e.latch_hash
   and e.gets - b.gets   > 0
 order by 1, 4
