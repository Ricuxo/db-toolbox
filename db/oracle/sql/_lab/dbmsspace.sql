set serveroutput on

declare
  TOTAL_BLOCKS              number;
  TOTAL_BYTES               number;
  UNUSED_BLOCKS             number;
  UNUSED_BYTES              number;
  LAST_USED_EXTENT_FILE_ID  number;
  LAST_USED_EXTENT_BLOCK_ID number;
  LAST_USED_BLOCK           number;
  pct_used                  number;
  CURSOR C1 IS select owner,segment_name from dba_segments where tablespace_name='TS_FID_GD01';

begin
 for r1 in c1 loop
 begin
  dbms_space.unused_space(r1.owner,r1.segment_name,'TABLE',
     TOTAL_BLOCKS, TOTAL_BYTES, UNUSED_BLOCKS, UNUSED_BYTES,
     LAST_USED_EXTENT_FILE_ID, LAST_USED_EXTENT_BLOCK_ID,
     LAST_USED_BLOCK);

  pct_used := (8192-UNUSED_BLOCKS)/8192*100;
  dbms_output.put_line(rtrim(r1.owner,10)||' '||rtrim(r1.segment_name,25)||' '||TOTAL_BLOCKS||' '||UNUSED_BLOCKS||' '||pct_used);
 end;
 end loop;
end;
/

