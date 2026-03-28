/*  */
create or replace function time_delta (date1 IN DATE, date2 IN DATE)
return varchar2 as
 date3 date;
 hr1  number;
 min1  number;
 sec1  number;
 hr2  number;
 min2 number;
 sec2  number;
 secs1 number;
 secs2 number;
 delta number;
begin
 hr1:=to_number(to_char(date1, 'hh24'));
 min1:=to_number(to_char(date1, 'mi'));
 sec1:=to_number(to_char(date1, 'ss'));
 secs1:=(hr1*3600)+(min1*60)+sec1;
 hr2:=to_number(to_char(date2, 'hh24'));
 min2:=to_number(to_char(date2, 'mi'));
 sec2:=to_number(to_char(date2, 'ss'));
 secs2:=(hr2*3600)+(min2*60)+sec2;
 if date1>date2 then
   delta:=secs1-secs2;
 else
   delta:=secs2-secs1;
 end if;
 select trunc(sysdate)+(delta/86400) into date3 from dual;
 dbms_output.put_line(to_char((date3), 'hh24:mi:ss'));
 return to_char((date3), 'hh24:mi:ss');
end;
/
