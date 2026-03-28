/*  */
create or replace procedure flush_it(p_free IN NUMBER) as
pfree NUMBER;
-- Define cursor to get current used shared pool
cursor get_share is
 select sum(bytes) from
  v$sgastat where pool='shared pool' and name <>'free memory';
-- Define cursor to get max defined shared pool size
cursor get_var is
 select value from v$parameter where name = 'shared pool size';
-- Set variables
mem_ratio number;
share_mem number;
variable_mem number;
cur integer;
sql_com varchar2(60);
row_proc number;
-- Process 
begin
 open get_share;
 open get_var;
 fetch get_share into share_mem;
dbms_output.put_line('share_mem: '||to_char(share_mem));
 fetch get_var into variable_mem;
dbms_output.put_line('variable_mem: '||to_char(variable_mem));
 mem_ratio:=share_mem/variable_mem;
dbms_output.put_line(to_char(mem_ratio));
 if p_free<1 THEN
   pfree:=p_free*100;
 else
   pfree:=p_free;
 end if;
 if mem_ratio>(pfree/100) Then
  cur:=dbms_sql.open_cursor;
  sql_com:='alter system flush shared_pool';
  dbms_sql.parse(cur,sql_com,dbms_sql.v7);
  row_proc:=dbms_sql.execute(cur);
  dbms_sql.close_cursor(cur);
  commit;
 end if;
end;
