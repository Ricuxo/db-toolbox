
set feed on head on arraysize 1  space 1 verify off lines 80 termout on
set serveroutput on size 1000000

declare
	P_USER_ROLE		dba_users.username%type := trim(upper('&schema_or_role'));
	V_USER_OR_ROLE	dba_users.username%type;
  --
	procedure SHOW(P_IN in varchar2, P_LEVEL NUMBER DEFAULT 0,P_TEXT varchar2 default '', P_TITLE number default 999) is
		V_TAB  varchar2(50);
	begin
		V_TAB:=RPAD(CHR(9),P_LEVEL,chr(9));	
		if P_TITLE = 1 then
			dbms_output.put_line(V_TAB||P_TEXT);
		end if;
		dbms_output.put_line(V_TAB||P_IN);
	end SHOW;        
    --
	function user_or_role(P_GRANTEE in dba_users.username%type) 
	return varchar2 is
	--
		V_RETURN	dba_users.username%type;
	begin
		for i in ( select 'USER' UTP from dba_users u where u.username=P_GRANTEE
				       union 
				   select 'ROLE' UTP from dba_roles r where  r.role=P_GRANTEE	
				 ) loop
	        V_RETURN:=i.UTP;
		end loop;
		return nvl(V_RETURN,'OTHER');
	exception	when others then
		SHOW('ERROR (user_or_role) => '||sqlcode);
		SHOW('MSG (user_or_role) => '||sqlerrm);
	end user_or_role;
  --
	procedure get_priv (P_USER_ROLE in varchar2) is
-- GET_ALL_TREE
		procedure get_all_tree(P_USER_ROLE varchar2,P_TABs in number) is 
			V_TABs number:=P_TABs+1;
		begin
			V_USER_OR_ROLE:=user_or_role(P_USER_ROLE);
			FOR j in (select rownum rn,granted_role r,decode(admin_option,'YES',' granted with admin option','') a from dba_role_privs where grantee=P_USER_ROLE) loop
				SHOW('Role: '||j.r||j.a,V_TABs,'--- Granted Roles ---',j.rn);
				get_all_tree(j.r,V_TABs);
			end loop;
			--FOR j in (select rownum rn,	privilege||' on '||owner||'.'||table_name||decode(GRANTABLE,'YES',' granted with grant option','') a from dba_tab_privs where grantee=P_USER_ROLE) loop
				--SHOW(j.a,V_TABs,'--- Granted Objects ---',j.rn);
			--end loop;
			FOR j in (  select rownum rn,privilege||decode(ADMIN_OPTION,'YES',' granted with admin option','') a from dba_sys_privs where grantee=P_USER_ROLE) loop
				SHOW(j.a,V_TABs,'--- Granted System Privileges ---',j.rn);
			end loop;
		end get_all_tree;

	Begin
		V_USER_OR_ROLE:=user_or_role(P_USER_ROLE);
		SHOW('==> '||V_USER_OR_ROLE||'('||P_USER_ROLE||') - privilege tree');
		get_all_tree(P_USER_ROLE,0);
  end get_priv;
begin
 	SHOW(' '||CHR(10));
  SHOW('====================================================================');
	get_priv(P_USER_ROLE);
exception when others then
	SHOW('ERROR (main) => '||sqlcode);
	SHOW('MSG (main) => '||sqlerrm);
end;
/


