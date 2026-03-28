/*  */
col owner format a20
col name format a30
col type format a10
col text format a45
set lines 132 pages 47 sqlbl on
@title132 'Objects Using SET RBS Commands'
spool rep_out\&db\rbs_set
select a.owner,a.name,a.type,trim(a.text) text 
from dba_source a, dba_objects b
where (a.text like '%RBS_1GB%' or text like '%RBS1%') 
      and trim(a.text) not like '--%'
      and a.name=b.object_name
      and a.owner=b.owner
      and a.type=b.object_type
      and b.status='VALID'
/
spool off
set lines 80 pages 22
undef columns
