set serveroutput on

declare
cursor c_profiles is
select PROFILE, RESOURCE_NAME, LIMIT
from dba_profiles
order by profile, resource_name;

s_PROFILE dba_profiles.PROFILE%type ;
s_prev_PROFILE dba_profiles.PROFILE%type ;
s_RESOURCE_NAME dba_profiles.RESOURCE_NAME%type ;
s_LIMIT dba_profiles.LIMIT%type ;
begin

s_prev_PROFILE := 'no_such_profile' ;

dbms_output.enable(1000000);
open c_profiles;
loop
fetch c_profiles into s_PROFILE,s_RESOURCE_NAME,s_LIMIT ;
if ( s_prev_profile <> s_profile ) then
begin
dbms_output.put_line ( '–');
dbms_output.put_line ( 'create profile "'||s_profile||'" limit ' ||s_RESOURCE_NAME|| ' ' || s_LIMIT||';' ) ;
s_prev_profile := s_profile ;
end;
else
dbms_output.put_line ( 'alter profile "'||s_profile|| '" limit ' ||s_RESOURCE_NAME|| ' ' || s_LIMIT || ';' ) ;
end if;
exit when c_profiles%NOTFOUND ;
end loop ;

close c_profiles ;

end;
/