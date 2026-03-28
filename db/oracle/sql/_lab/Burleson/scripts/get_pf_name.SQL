/*  */
create or replace procedure test_proc is
l_format varchar2(2000);
skip number;
start_position number;
end_position number;
proc_name varchar2(100);

begin
l_format := dbms_utility.format_call_stack;

skip := INSTR(l_format, 'procedure');
skip := INSTR(l_format, CHR(10), skip) + 1;
start_position := INSTR(l_format, 'procedure', skip);
if start_position = 0 then
start_position:=length(l_format) + 1;
end if;
skip := INSTR(l_format, 'function', skip);
if skip = 0 then
skip:=length(l_format) + 1;
end if;
if skip < start_position then
start_position := skip;
end if;

start_position := InStr(l_format, ' ', start_position) + 1;
end_position := INSTR(l_format, CHR(10), start_position);

proc_name := SUBSTR(l_format, start_position, end_position -
start_position);

dbms_output.put_line(l_format);
dbms_output.put_line('OBJECT NAME = (' || proc_name || ')');

end;
/
