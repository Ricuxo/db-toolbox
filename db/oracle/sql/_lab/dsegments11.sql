set pagesize 999
set linesize 165

column owner format a30
column segment_name format a30
column partition_name format a30
column segment_type format a18
column segment_subtype format a10
column tablespace_name format a30
column size_mb format 9999999,99

select owner
     , substr(segment_name, 1, 30) segment_name
     , partition_name
     , segment_type
     , segment_subtype
     , tablespace_name
     , trunc(sum(bytes)/1024/1024, 2) SIZE_MB
  from dba_segments
 where owner like NVL('&LKOWNER', owner)
   and segment_name like NVL('&LKSEGMENT', segment_name)
 group by owner
        , segment_name
        , partition_name
        , segment_type
        , segment_subtype
        , tablespace_name
/
