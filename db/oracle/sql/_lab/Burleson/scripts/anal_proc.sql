/*  */
rem Method not recommended for Oracle 8i+ deprecated in favor of dbms_stats package.
create table anal_test as select * from dba_tables where rownum<1;
truncate table anal_test;
declare
no_of_rows integer;
anal_string varchar2(128);
cur_num integer;
anal_count integer;
begin
for anal_count in 5..45 loop
if mod(anal_count,5)=0 then
cur_num:=dbms_sql.open_cursor;
anal_string:='analyze table s_ord estimate statistics sample '||to_char(anal_count)||' percent';
DBMS_SQL.PARSE(cur_num,anal_string,dbms_sql.native);
no_of_rows := DBMS_SQL.EXECUTE(cur_num);
DBMS_SQL.CLOSE_CURSOR(cur_num);
insert into anal_test select * from dba_tables where table_name='S_ORD';
commit;
cur_num:=dbms_sql.open_cursor;
anal_string:='analyze table s_ord delete statistics';
DBMS_SQL.PARSE(cur_num,anal_string,dbms_sql.native);
no_of_rows := DBMS_SQL.EXECUTE(cur_num);
DBMS_SQL.CLOSE_CURSOR(cur_num);
end if;
end loop;
for anal_count in 50..4500 loop
if mod(anal_count,50)=0 then
cur_num:=dbms_sql.open_cursor;
anal_string:='analyze table s_ord estimate statistics sample '||to_char(anal_count)||' rows';
DBMS_SQL.PARSE(cur_num,anal_string,dbms_sql.native);
no_of_rows := DBMS_SQL.EXECUTE(cur_num);
DBMS_SQL.CLOSE_CURSOR(cur_num);
insert into anal_test select * from dba_tables where table_name='S_ORD';
commit;
cur_num:=dbms_sql.open_cursor;
anal_string:='analyze table s_ord delete statistics';
DBMS_SQL.PARSE(cur_num,anal_string,dbms_sql.native);
no_of_rows := DBMS_SQL.EXECUTE(cur_num);
DBMS_SQL.CLOSE_CURSOR(cur_num);
end if;
end loop;
end;
/
