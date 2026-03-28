/*  */
column tablespace_name heading 'Tablespace|Name'
column extent_management heading 'Extent|Management'
column segment_space_management heading 'Segment Space|Management'
@title80 'Tablespace Options'
spool rep_out\&db\tbsp_opt
select tablespace_name,extent_management,segment_space_management from dba_tablespaces
/
spool off
clear columns
ttitle off
