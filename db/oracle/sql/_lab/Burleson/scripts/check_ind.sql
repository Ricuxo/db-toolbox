/*  */
rem check_ind.sql
rem FUNCTION: SHow which indexes are in the SGA
rem MRA
rem
start title80 'Indexes in SGA'
spool rep_out\&db\check_ind
select owner||'.'||object_name, count(*)
from dba_objects o, x$bh bh
where bh.obj = o.object_id
and o.object_type='INDEX'
group by owner,object_name;
spool off
ttitle off
