/*  */
create or replace function get_count (tab_name varchar2) return number as
cur integer;
sql_text varchar2(200);
rowcount integer;
row_proc integer;
BEGIN
    cur:=dbms_sql.open_cursor;
    sql_text:='select count(1) rowcount from '||tab_name||';';
    dbms_sql.parse(cur,sql_text,dbms_sql.v7);
    dbms_sql.define_column(cur,1,rowcount);
    row_proc:=dbms_sql.execute(cur);
    dbms_sql.column_value(cur,1,rowcount);
    dbms_sql.close_cursor(cur);
    return rowcount;
end;
/
