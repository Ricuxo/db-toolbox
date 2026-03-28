/*  */
create or replace function get_sum(table_name in varchar2)
return number as
sum_bytes number;
BEGIN
select sum(bytes) into sum_bytes from dba_extents where segment_name=table_name
and segment_type='TABLE';
RETURN sum_bytes;
end;
/
