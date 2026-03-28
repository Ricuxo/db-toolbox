/*  */
set serveroutput on
set verify off
declare
v1 number;
v2 number;
v3 number;
v4 number;
v5 number;
v6 number;
v7 number;
emax number;
euse number;
eublk number;
fp number;
begin

dbms_space.unused_space(upper('&&schema'), upper('&&segment'),
upper('&&segtype'),v1,v2,v3,v4,v5,v6,v7);

select max(extent_id) into emax
from sys.dba_extents
where
owner = upper('&&SCHEMA')
and segment_name = upper('&&SEGMENT');

select extent_id, blocks into euse, eublk
from sys.dba_extents
where
owner = upper('&&SCHEMA')
and segment_name = upper('&&SEGMENT')
and file_id = v5
and block_id = v6;

fp := (v4 * 100) / v2;
dbms_output.put_line (' ');
dbms_output.put_line ('Schema: '||'&&schema'||' Segment: '||'&&segment'||' Type: '||'&&segtype');
dbms_output.put_line ('total_blocks '||v1);
dbms_output.put_line ('total_bytes '||v2);
dbms_output.put_line ('unused_blocks '||v3);
dbms_output.put_line ('unused_bytes '||v4||' = '||
ltrim(to_char(fp,'999'))||'%');
dbms_output.put_line ('last_used_extent '||euse||'/'||emax);
dbms_output.put_line ('last_used_extent_file_id '||v5);
dbms_output.put_line ('last_used_extent_block_id '||v6);
dbms_output.put_line ('last_used_block '||v7);
dbms_output.put_line ('last_used_extent_blocks '||eublk);
end;
/
undef schema
undef segment
undef segtype
set serveroutput off
set verify on
