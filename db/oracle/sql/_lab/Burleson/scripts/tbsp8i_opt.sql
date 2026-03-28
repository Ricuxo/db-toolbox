/*  */
column tablespace_name heading 'Tablespace|Name'
column extent_management heading 'Extent|Management'
@title80 'Tablespace 8i Options'
spool rep_out\&db\tbsp8i_opt
select tablespace_name,extent_management from dba_tablespaces
/
spool off
clear columns
ttitle off
