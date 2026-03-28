set linesize 300
set pagesize 999

select owner,
       object_type,
       object_name, 
       data_object_id
  from dba_objects
where object_id = &OBJECT_ID
/
