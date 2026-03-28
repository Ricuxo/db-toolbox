/*  */
rem
rem FUNCTION: Report objects that need to be recompiled
rem FUNCTION: because they may be hanging
rem FUNCTION: run from SYS only
rem
@title80 "Objects that need Recompilation"
column obj# heading Object|Number
column name heading Object|Name
column owner# heading Owner|Number
spool rep_out\&db\hanging
select distinct o2.obj#,o2.name, o2.owner#
from sys.obj$ o,
     sys.dependency$ d,
     sys.obj$ o2
where o.obj# = d.p_obj#
and o.stime != d.p_timestamp
and d.d_obj# = o2.obj#
and o2.status != 5
order by o2.obj#
/
spool off
clear columns
ttitle off
