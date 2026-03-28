/*  */
select
    c.username username,
    count(a.hash_value) scan_count 
from
    sys.v_$sql_plan a, 
    sys.dba_segments b, 
    sys.dba_users c, 
    sys.v_$sql d 
where
     a.object_owner (+) = b.owner 
and
     a.object_name (+) = b.segment_name 
and
     b.segment_type IN ('TABLE', 'TABLE PARTITION') 
and
     a.operation like '%TABLE%' 
and
     a.options = 'FULL' 
and
     c.user_id = d.parsing_user_id 
and
     d.hash_value = a.hash_value 
and
     b.bytes / 1024 > 1024 
group by
     c.username 
order by
     2 desc
;
