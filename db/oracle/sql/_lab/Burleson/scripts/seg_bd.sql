/*  */
set lines 80 pages 47
break on tablespace_name on ts#
@title80 "Segment Breakdown"
spool rep_out\&db\seg_bd
select a.tablespace_name, b.ts#, a.segment_type, count(*) "Number" from sys.ts$ b,
dba_segments a where b.name=a.tablespace_name group by b.ts#,a.tablespace_name,a.segment_type
/
spool off
