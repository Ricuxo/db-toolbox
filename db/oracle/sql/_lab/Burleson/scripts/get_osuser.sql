/*  */
create or replace function get_osuser 
return varchar2 as
cursor get_user is
select 
	distinct decode(s.osuser,null,'Internal',s.osuser) 
from 
	v$session s, 
	v$process p
where 
        p.addr=s.paddr
	and user=s.username;
username varchar2(255);
begin
open get_user;
fetch get_user into username;
close get_user;
return username;
end;
/
