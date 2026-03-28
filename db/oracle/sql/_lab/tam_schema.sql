select
segment_type, sum(bytes/1024/1024) size_in_mbytes
from
dba_segments
where
OWNER = '&1'
group by
segment_type;