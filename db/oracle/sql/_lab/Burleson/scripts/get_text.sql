/*  */
create or replace function get_text (address IN RAW) 
return varchar2 as
sql_text varchar2(32000);
cursor get_sql(address_in RAW) is
select sql_text from v$sqltext where address=address_in
order by piece;
sql_rec get_sql%rowtype;
begin
for sql_rec in get_sql(address) loop
sql_text:=sql_text||sql_rec.sql_text;
end loop;
return substr(sql_text,1,4000);
end;

