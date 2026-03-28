set linesize 6000
column owner format A30
column directory_name format A30
column directory_path format A4000

select owner
     , directory_name
     , directory_path 
  from dba_directories
 where directory_name like nvl('&DIRNAME',directory_name)
   and directory_path like nvl('&DIRPATH',directory_path)
/

@reset
