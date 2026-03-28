/*  */
create procedure do_a_view as
cur integer;
processed integer;
begin
cur:=dbms_sql.open_cursor;
dbms_sql.parse (cur,'create view testing as select * from test',dbms_sql.v7);
processed:=dbms_sql.execute(cur);
dbms_sql.close_cursor(cur);
end;
/
