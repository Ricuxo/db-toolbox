/*  */
create or replace procedure flush_it(p_free IN NUMBER) as
cursor get_share is
SELECT 
  SUM(bytes)
FROM  
  v$sgastat 
WHERE 
  name in ( 
  'reserved stopper',             
  'table definiti',                  
  'dictionary cache',           
  'library cache',              
  'sql area',
  'PL/SQL DIANA',
  'SEQ S.O.'); 
cursor get_var is
 select value from v$parameter where name like 'shared_pool_size';
cursor get_time is 
 select sysdate from dual;
  todays_date date;
  mem_ratio number;
share_mem number;
variable_mem number;
cur integer;
sql_com varchar2(60);
row_proc number;
begin
 open get_share;
 open get_var;
 fetch get_share into share_mem;
dbms_output.put_line('share_mem: '||to_char(share_mem));
 fetch get_var into variable_mem;
dbms_output.put_line('variable_mem: '||to_char(variable_mem));
 mem_ratio:=share_mem/variable_mem;
dbms_output.put_line(to_char(mem_ratio));
 if mem_ratio>(p_free/100) Then
  cur:=dbms_sql.open_cursor;
  sql_com:='alter system flush shared_pool';
  dbms_sql.parse(cur,sql_com,dbms_sql.v7);
  row_proc:=dbms_sql.execute(cur);
  dbms_sql.close_cursor(cur);
  open get_time;
  fetch get_time into todays_date;
  insert into dba_running_stats values ('Flush of Shared Pool',mem_ratio,35,todays_date,0);
  commit;
 end if;
end;
