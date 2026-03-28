select 
   sum(bytes/1024/1024) 
from 
   dba_segments 
where 
   segment_name='MYTABLE';


select 
   owner, 
   segment_name, 
   partition_name, 
   segment_type, 
   bytes / 1024/1024 "MB" 
from 
   dba_segments 
where 
   segment_name in ('SEG1','SEG2','SEG3');

select 
   owner,
   segment_name,
   partition_name,segment_type,bytes/1024/1024 "MB"
from 
   dba_segments 
where 
   segment_type = 'TABLE PARTITION';


set serveroutput on
declare
l_fs1_bytes number;
l_fs2_bytes number;
l_fs3_bytes number;
l_fs4_bytes number;
l_fs1_blocks number;
l_fs2_blocks number;
l_fs3_blocks number;
l_fs4_blocks number;
l_full_bytes number;
l_full_blocks number;
l_unformatted_bytes number;
l_unformatted_blocks number;
v_segname varchar2(500);
begin 
dbms_space.space_usage( 
segment_owner => 'SCOTT,
segment_name => 'EMP, 
segment_type => 'TABLE', 
fs1_bytes => l_fs1_bytes,
fs1_blocks => l_fs1_blocks, 
fs2_bytes => l_fs2_bytes,
fs2_blocks => l_fs2_blocks, 
fs3_bytes => l_fs3_bytes,
fs3_blocks => l_fs3_blocks,
fs4_bytes => l_fs4_bytes,
fs4_blocks => l_fs4_blocks,
full_bytes => l_full_bytes,
full_blocks => l_full_blocks,
unformatted_blocks => l_unformatted_blocks,
unformatted_bytes => l_unformatted_bytes
);
dbms_output.enable;
dbms_output.put_line('=============================================');
dbms_output.put_line('total blocks = '||to_char(l_fs1_blocks + l_fs2_blocks +
l_fs3_blocks + l_fs4_blocks + l_full_blocks)|| ' || total bytes = '||
to_char(l_fs1_bytes + l_fs2_bytes +
l_fs3_bytes + l_fs4_bytes + l_full_bytes));
end;
/
