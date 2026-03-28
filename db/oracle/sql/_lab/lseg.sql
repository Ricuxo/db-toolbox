set pagesize 1000
set linesize 200
col segment_name format a30
select owner,segment_name,segment_type,extents,bytes/1024 from dba_segments where tablespace_name='&tbs' order by 5
/
