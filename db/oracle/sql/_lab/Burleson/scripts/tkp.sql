/*  */
drop table tkp_example2
/
create table tkp_example2 as
select a.owner, a.object_name, a.object_type, b.tablespace_name
from dba_objects a, dba_segments b
where
b.owner(+)=a.owner and
b.segment_name(+)=a.object_name
/
