/*  */
SELECT a.file#,decode(b.segment_name,null,'UNUSED',b.segment_name) segment_name,
       COUNT(a.block#) Blocks,
       COUNT (DISTINCT a.file# || a.block#) Distinct_blocks
   FROM V$BH a, dba_extents b
   WHERE a.file#=b.file_id(+)
   and b.file_id=&file_id
   and a.block# between b.block_id and b.block_id+b.blocks
   GROUP BY a.file#,decode(b.tablespace_name,null,'UNUSED',b.tablespace_name)
/
