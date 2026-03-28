set pages 0;
set linesize 100;
set feedback off;
set verify off;

spool user_privs_clone.sql
-- user itself
select 'create user &&new_user identified by values '''||password||''' '||
' default tablespace '||default_tablespace||
' temporary tablespace '||temporary_tablespace||' profile '||
profile||';'
from sys.dba_users
where username = upper('&&cur_user');

-- user roles
select 'grant '||granted_role||' to &&new_user'||
decode(ADMIN_OPTION, 'YES', ' WITH ADMIN OPTION')||';'
from sys.dba_role_privs
where grantee = upper('&&cur_user');

-- system privileges
select 'grant '||privilege||' to &&new_user'||
decode(ADMIN_OPTION, 'YES', ' WITH ADMIN OPTION')||';'
from sys.dba_sys_privs
where grantee = upper('&&cur_user');

-- table privileges
select 'grant '||privilege||' on '||owner||'.'||table_name||' to &&new_user;'
from sys.dba_tab_privs
where grantee = upper('&&cur_user');


-- column privileges
select 'grant '||privilege||' on '||owner||'.'||table_name||
'('||column_name||') to &&new_user;'
from sys.dba_col_privs
where grantee = upper('&&cur_user');


-- tablespace quotas
select 'alter user '||username||' quota '||
decode(MAX_BYTES,-1,'UNLIMITED', to_char(MAX_BYTES/(1024*1024),'9999') || 'M')||
' on '||tablespace_name||';'
from sys.dba_ts_quotas
where username = upper('&&cur_user');


-- default roles
set serveroutput on;
declare
defroles varchar2(4000);
begin
for c1 in (select * from sys.dba_role_privs
where grantee = upper('&&cur_user')
and default_role = 'YES'
) loop
if length(defroles) > 0 then
defroles := defroles||',
'||c1.granted_role;
else
defroles := defroles||c1.granted_role;
end if;
end loop;
dbms_output.put_line('alter user &&new_user default role '||defroles||';');
end;
/

set serveroutput off;
undef cur_user
undef new_user
spool off;