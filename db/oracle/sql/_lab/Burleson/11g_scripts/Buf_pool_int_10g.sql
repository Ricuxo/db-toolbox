/*  */
select
     name
     , numbufs  "Number of Buffers"
     , buffs "Buffer Gets"
     , conget   "Consistent Gets"
     , phread  "Physical Reads"
     , phwrite  "Physical Writes"
     , fbwait  "Free Buffer Waits"
     , bbwait "Buffer Busy Waits"
     , wcwait  "Write Complete Waits"
     , poolhr "Pool Hit %"
From
(select e.name
      , e.set_msize                                            numbufs
      , decode(   e.db_block_gets     - nvl(b.db_block_gets,0)
              +  e.consistent_gets   - nvl(b.consistent_gets,0)
             , 0, to_number(null)
             , (100* (1 - (  (e.physical_reads - nvl(b.physical_reads,0))
                           / (  e.db_block_gets     - nvl(b.db_block_gets,0)
                              + e.consistent_gets   - nvl(b.consistent_gets,0))
                          )
                     )
               )
             )                                                poolhr
     ,    e.db_block_gets    - nvl(b.db_block_gets,0)
       +  e.consistent_gets  - nvl(b.consistent_gets,0)       buffs
     , e.consistent_gets     - nvl(b.consistent_gets,0)       conget
     , e.physical_reads      - nvl(b.physical_reads,0)	      phread
     , e.physical_writes     - nvl(b.physical_writes,0)       phwrite
     , e.free_buffer_wait    - nvl(b.free_buffer_wait,0)      fbwait
     , e.write_complete_wait - nvl(b.write_complete_wait,0)   wcwait
     , e.buffer_busy_wait    - nvl(b.buffer_busy_wait,0)      bbwait
  from dba_hist_buffer_pool_stat  b
     , dba_hist_buffer_pool_stat  e
 where b.snap_id(+)         = &pBgnSnap
   and e.snap_id            = &pEndSnap
   and b.dbid(+)            = &pDbId
   and e.dbid               = &pDbId
   and b.dbid(+)            = e.dbid
   and b.instance_number(+) = &pInst_Num
   and e.instance_number    = &pInst_Num
   and b.instance_number(+) = e.instance_number
   and b.id(+)              = e.id)
 order by 1
