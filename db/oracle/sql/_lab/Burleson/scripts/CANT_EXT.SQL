/*  */
rem cant_ext.sql
rem FUNCTION: SHow objects that can't extend
rem MRA
rem
column owner format a10
column segment_name format a20
column tablespace_name format a15 heading tablespace
@title132 'Objects Which Cannot Extend'
spool rep_out/&db/cant_ext
SELECT seg.owner, seg.segment_name,
   seg.segment_type, seg.tablespace_name,
   DECODE(seg.segment_type,
      'TABLE', t.next_extent,
      'CLUSTER', c.next_extent,
      'INDEX', i.next_extent,
      'ROLLBACK', r.next_extent) Obj_type
FROM sys.dba_segments seg,
   sys.dba_tables t,
   sys.dba_clusters c,
   sys.dba_indexes i,
   sys.dba_rollback_segs r
WHERE ((seg.segment_type = 'TABLE'
   AND seg.segment_name = t.table_name
   AND seg.owner = t.owner
   AND NOT EXISTS (SELECT tablespace_name
      FROM dba_free_space free
      WHERE free.tablespace_name = t.tablespace_name
      AND free.bytes >= t.next_extent))
OR (seg.segment_type = 'CLUSTER'
   AND seg.segment_name = c.cluster_name
   AND seg.owner = c.owner
   AND NOT EXISTS (SELECT tablespace_name
      FROM dba_free_space free
      WHERE free.tablespace_name = c.tablespace_name
      AND free.bytes >= c.next_extent))
OR (seg.segment_type = 'INDEX'
   AND seg.segment_name = i.index_name
   AND seg.owner = i.owner
   AND NOT EXISTS (SELECT tablespace_name
      FROM dba_free_space free
      WHERE free.tablespace_name = i.tablespace_name
      AND free.bytes >= i.next_extent))
OR     (seg.segment_type = 'ROLLBACK'
   AND seg.segment_name = r.segment_name
   AND seg.owner = r.owner
   AND NOT EXISTS (SELECT tablespace_name
      FROM dba_free_space free
      WHERE free.tablespace_name = r.tablespace_name
     AND free.bytes >= r.next_extent)))
OR seg.extents = seg.max_extents OR seg.extents = (select value from v$parameter where
name='db_block_size')
/
spool off
ttitle off
