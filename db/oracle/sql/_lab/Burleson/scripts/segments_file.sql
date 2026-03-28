/*  */
col owner format a10
col segment_name format a30
col segment_type format a20
SELECT distinct owner, segment_name, segment_type
    FROM dba_extents
   WHERE file_id= &FILE_ID
  
/
