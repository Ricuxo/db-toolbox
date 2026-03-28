/*  */
create or replace procedure kill_session ( session_id in varchar2,
serial_num in varchar2)
as
cur integer;
ret integer;
string varchar2(100);
begin
 string :=
        'alter system kill session '||''''||session_id||','||serial_num||'''';
   cur := dbms_sql.open_cursor;
   dbms_sql.parse(cur,string,dbms_sql.v7);
   ret := dbms_sql.execute(cur)  ;
   dbms_sql.close_cursor(cur);
exception
   when OTHERS then
      raise_application_error(-20001,'Error in execution',TRUE);
      if dbms_sql.is_open(cur) then
        dbms_sql.close_cursor(cur);
      end if;
end;
/
