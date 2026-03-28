/*  */
select tbsp “Tablespace”
     , ios "I/O Activity"
From (
select e.tsname tbsp
     , sum (e.phyrds  - nvl(b.phyrds,0))  +
       sum (e.phywrts - nvl(b.phywrts,0)) ios
  from dba_hist_filestatxs  e
     , dba_hist_filestatxs  b
 where b.snap_id(+)         = &pBgnSnap
   and e.snap_id            = &pEndSnap
   and b.dbid(+)            = &pDbId
   and e.dbid               = &pDbId
   and b.dbid(+)            = e.dbid
   and b.instance_number(+) = &pInstNum
   and e.instance_number    = &pInstNum
   and b.instance_number(+) = e.instance_number
   and b.file#              = e.file#
   and ( (e.phyrds  - nvl(b.phyrds,0) ) +
         (e.phywrts - nvl(b.phywrts,0)) ) > 0
 group by e.tsname
union
select e.tsname tbsp
     , sum (e.phyrds  - nvl(b.phyrds,0))  +
       sum (e.phywrts - nvl(b.phywrts,0)) ios
  from dba_hist_tempstatxs  e
     , dba_hist_tempstatxs  b
 where b.snap_id(+)         = &pBgnSnap
   and e.snap_id            = &pEndSnap
   and b.dbid(+)            = &pDbId
   and e.dbid               = &pDbId
   and b.dbid(+)            = e.dbid
   and b.instance_number(+) = &pInstNum
   and e.instance_number    = &pInstNum
   and b.instance_number(+) = e.instance_number
   and b.file#              = e.file#
   and ( (e.phyrds  - nvl(b.phyrds,0) ) +
         (e.phywrts - nvl(b.phywrts,0) ) ) > 0
 group by e.tsname
)
