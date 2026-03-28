/*  */
col owner format a20
col mview_name format a32
col right_now new_value now noprint
set lines 132 pages 47
@title132 'Materialized View Status'
select to_char(sysdate,'ddmonyyyyhh24mi') right_now from dual;
spool rep_out\&&db\mview_state&&now
select owner,mview_name,staleness,compile_state from dba_mviews
/
spool off
set lines 80 pages 24
clear columns
ttitle off
