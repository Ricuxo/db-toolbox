/*  */
col owner format a10
@title80 'Materilaized View Status'
spool rep_out\&db\mv_status
set lines 80 pages 47
select 
     owner,
     mview_name,
     staleness,
     compile_state
from dba_mviews
order by owner;
spool off
set pages 22
ttitle off

