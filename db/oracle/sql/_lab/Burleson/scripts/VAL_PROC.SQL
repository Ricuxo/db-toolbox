/*  */
create or replace package dbms_local is
procedure validate_index (schema in varchar2, index_name in varchar2,table_name in varchar2);
end dbms_local;
/
create or replace package body dbms_local is
procedure validate_index (schema in varchar2, index_name in varchar2,table_name in varchar2)
is
cid1 integer;
cid2 integer;
rows_processed integer;
begin
cid1:=dbms_sql.open_cursor;
cid2:=dbms_sql.open_cursor;
dbms_output.put_line('ANALYZE INDEX '||schema||'.'||index_name||' validate structure  '||table_name);
dbms_sql.parse(cid1,'ANALYZE INDEX '||schema||'.'||index_name||' validate structure',dbms_sql.v7);
dbms_sql.parse(cid2,'INSERT INTO '||table_name||' SELECT * FROM index_stats ',dbms_sql.v7);
rows_processed:=dbms_sql.execute(cid1);
rows_processed:=dbms_sql.execute(cid2);
commit;
dbms_sql.close_cursor(cid1);
dbms_sql.close_cursor(cid2);
end validate_index;
end dbms_local;
/
