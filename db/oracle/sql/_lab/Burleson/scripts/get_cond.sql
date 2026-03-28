/*  */
create or replace function get_cond(con_name varchar2, owner_name varchar2)
return varchar2 as
ser_cond varchar2(2000);
begin
select search_condition into ser_cond from user_constraints
where constraint_name=upper(con_name) and owner=upper(owner_name);
return ser_cond;
end;
/
