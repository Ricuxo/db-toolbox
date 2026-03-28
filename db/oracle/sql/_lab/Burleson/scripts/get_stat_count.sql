/*  */
create or replace procedure get_stat_rows(schema IN varchar2) as
tab_name varchar2(32);
rows number;
stat_rows number;
cursor get_tabs is
select table_name from dba_tables where owner=schema;
begin
open get_tabs;
loop
exit when get_tabs%notfound;
fetch get_tabs into tab_name;
dba_utilities.get_count(tab_name,rows);
select a.num_rows into stat_rows from dba_tables a where a.owner=schema 
 and a.table_name=tab_name;
dbms_output.put_line('Table: '||tab_name||' stat_rows: '||TO_CHAR(stat_rows)||' actual rows: '||to_char(rows));
end loop;
end;
/
