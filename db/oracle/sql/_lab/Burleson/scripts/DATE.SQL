/*  */
declare
jdate date;
jsec number;
hr number;
minute number;
sec1 number;
sec2 number;
sec number;
startup_date varchar2(25);
begin
select to_date(to_number(value,'99999999'),'J') into jdate from
v$instance where key='STARTUP TIME - JULIAN';
select (to_number(value,'9999999')) into jsec from v$instance
where key='STARTUP TIME - SECONDS';
hr:=trunc(jsec/3600,0);
minute:= trunc(((jsec/3600)-hr)*60,0);
/*sec1 := (jsec/3600)-hr;
sec2 := (sec1 * 60)-minute;
sec := trunc(sec2*60,0);*/
sec:= trunc((((((jsec/3600)-hr)*60)-minute)*60),0);
startup_date:=jdate||' '||to_char(hr)||':'||to_char(minute)||':'||
to_char(sec);
dbms_output.put_line('Startup Date: '||startup_date);
end;

