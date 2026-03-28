/*  */
declare
cursor get_io is select
	nvl(sum(a.phyrds+a.phywrts),0) sum_io1,
        nvl(sum(b.phyrds+b.phywrts),0) sum_io2,
        nvl(sum(a.phyrds+a.phywrts),0)+nvl(sum(b.phyrds+b.phywrts),0) tot_io
from
        sys.v_$filestat a,sys.v_$tempstat b;
now date;
elapsed_seconds number;
sum_io1 number;
sum_io2 number;
tot_io number;
tot_io_per_sec number;
fixed_io_per_sec number;
temp_io_per_sec number;
begin
open get_io;
fetch get_io into sum_io1, sum_io2, tot_io;
select sysdate into now from dual;
select ceil((now-startup_time)*(60*60*24)) into elapsed_seconds from v$instance;
fixed_io_per_sec:=sum_io1/elapsed_seconds;
temp_io_per_sec:=sum_io2/elapsed_seconds;
tot_io_per_sec:=tot_io/elapsed_seconds;
dbms_output.put_line('Elapsed Sec:'||to_char(elapsed_seconds));
dbms_output.put_line('Fixed IO/SEC:'||to_char(fixed_io_per_sec));
dbms_output.put_line('Temp IO/SEC:'||to_char(Temp_io_per_sec));
dbms_output.put_line('Total IO/SEC:'||to_char(Tot_IO_Per_Sec));
end;
/
