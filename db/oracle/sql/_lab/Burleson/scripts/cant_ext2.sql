/*  */
column owner format a10
column segment_name format a20
column tablespace_name format a15 heading tablespace
@title132 'Objects Which Cannot Extend'
spool rep_out/&db/cant_ext
SELECT seg.owner, seg.segment_name,
   seg.segment_type, seg.tablespace_name,
   t.next_extent 
FROM sys.dba_segments seg,
   sys.dba_tables t
WHERE (seg.segment_type = 'TABLE'
   AND seg.segment_name = t.table_name
   AND seg.owner = t.owner
   AND NOT EXISTS (SELECT tablespace_name
      FROM dba_free_space free
      WHERE free.tablespace_name = t.tablespace_name
      AND free.bytes >= t.next_extent))
UNION
SELECT seg.owner, seg.segment_name,
   seg.segment_type, seg.tablespace_name,
    c.next_extent
FROM sys.dba_segments seg,
   sys.dba_clusters c
WHERE (seg.segment_type = 'CLUSTER'
   AND seg.segment_name = c.cluster_name
   AND seg.owner = c.owner
   AND NOT EXISTS (SELECT tablespace_name
      FROM dba_free_space free
      WHERE free.tablespace_name = c.tablespace_name
      AND free.bytes >= c.next_extent))
UNION
SELECT seg.owner, seg.segment_name,
   seg.segment_type, seg.tablespace_name,
   i.next_extent
FROM sys.dba_segments seg,
   sys.dba_indexes i
WHERE (seg.segment_type = 'INDEX'
   AND seg.segment_name = i.index_name
   AND seg.owner = i.owner
   AND NOT EXISTS (SELECT tablespace_name
      FROM dba_free_space free
      WHERE free.tablespace_name = i.tablespace_name
      AND free.bytes >= i.next_extent))
UNION
SELECT seg.owner, seg.segment_name,
   seg.segment_type, seg.tablespace_name,
   r.next_extent
FROM sys.dba_segments seg,
   sys.dba_rollback_segs r
WHERE     (seg.segment_type = 'ROLLBACK'
   AND seg.segment_name = r.segment_name
   AND seg.owner = r.owner
   AND NOT EXISTS (SELECT tablespace_name
      FROM dba_free_space free
      WHERE free.tablespace_name = r.tablespace_name
     AND free.bytes >= r.next_extent))
/
spool off
