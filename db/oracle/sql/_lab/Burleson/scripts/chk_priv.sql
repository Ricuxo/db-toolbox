/*  */
create or replace function chk_priv(tab_name varchar2, priv varchar2)
return boolean is
	tab_nam varchar2(32);
	privil varchar2(30);
	priv_there boolean;
	cursor get_stat (tab varchar2, priv varchar2) is
		select table_name 
		from user_tab_privs 
		where table_name=upper(tab_name) and privilege=upper(priv);
begin
	open get_stat(tab_name,priv);
	fetch get_stat into tab_nam;
	if get_stat%rowcount<1
	then
		priv_there:=FALSE;
	else
		priv_there:=TRUE;
	end if;
	return priv_there;
end;
/
