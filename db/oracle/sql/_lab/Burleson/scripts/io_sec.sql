/*  */
set serveroutput on
declare
cursor get_io is select
        nvl(sum(a.phyrds+a.phywrts),0) sum_io1,to_number(null) sum_io2
from sys.v_$filestat a
union
select
        to_number(null) sum_io1, nvl(sum(b.phyrds+b.phywrts),0) sum_io2
from
        sys.v_$tempstat b;
now date;
elapsed_seconds number;
sum_io1 number;
sum_io2 number;
sum_io12 number;
sum_io22 number;
tot_io number;
tot_io_per_sec number;
fixed_io_per_sec number;
temp_io_per_sec number;
begin
open get_io;
for i in 1..2 loop
fetch get_io into sum_io1, sum_io2;
if i = 1 then sum_io12:=sum_io1;
else
sum_io22:=sum_io2;
end if;
end loop;
select sum_io12+sum_io22 into tot_io from dual;
select sysdate into now from dual;
select ceil((now-startup_time)*(60*60*24)) into elapsed_seconds from v$instance;
fixed_io_per_sec:=sum_io12/elapsed_seconds;
temp_io_per_sec:=sum_io22/elapsed_seconds;
tot_io_per_sec:=tot_io/elapsed_seconds;
dbms_output.put_line('Elapsed Sec :'||to_char(elapsed_seconds, '9,999,999.99'));
dbms_output.put_line('Fixed IO/SEC:'||to_char(fixed_io_per_sec,'9,999,999.99'));
dbms_output.put_line('Temp IO/SEC :'||to_char(temp_io_per_sec, '9,999,999.99'));
dbms_output.put_line('Total IO/SEC:'||to_char(tot_io_Per_Sec,  '9,999,999.99'));
end;
/
