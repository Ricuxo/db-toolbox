/*  */
col owner format a15 heading 'Owner'
col segment_name format a27 heading 'Segment|Name'
col tablespace_name format a15 heading 'Tablespace'
column extents format 9,999 heading 'Extents'
column bytes format 99,999 heading 'Meg'
col segment_type format a10 heading 'Segment|Type'
start title80 'Lob Segments'
set lines 90
spool rep_out\&db\lob_seg
select owner,segment_name,segment_type,tablespace_name,extents,bytes/(1024*1024) bytes from dba_segments where owner not in ('SYS','SYSTEM','PRECISE','MAULT','PATROL','QDBA','OUTLN','XDB','WMSYS','MDSYS','CTXSYS','ODM','SYSMAN') and segment_type like 'LOB%'
/
spool off
ttitle off
