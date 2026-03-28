/*  */
rem vbh_status.sql
rem
rem Mike Ault -- Burleson Consulting
rem
@title80 'Status of DB Block Buffers'
spool rep_out\&db\vbh_status
select status,count(*) number_buffers from v$bh group by status;
spool off
ttitle off

