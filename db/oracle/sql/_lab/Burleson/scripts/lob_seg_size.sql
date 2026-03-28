/*  */
col owner format a12 heading 'Owner'
col segment_name format a27 heading 'Segment|Name'
col tablespace_name format a15 heading 'Tablespace|Name'
col extents format 999,999,999 heading 'Extents'
col bytes format 999,999,999,999 heading 'Bytes'
set lines 132 pages 50 verify off feedback off
start title132 'Lob Segment Sizes'
spool rep_out\&db\lob_seg_size
select owner,segment_name,segment_type,tablespace_name,extents,bytes from dba_segments
where owner not in ('SYS','SYSTEM','PRECISE','MAULT','PATROL','QDBA','OUTLN','XDB','WMSYS','MDSYS','CTXSYS','ODM','SYSMAN') and segment_type LIKE 'LOB%'
/
spool off
set lines 80 pages 22 feedback on
ttitle off
