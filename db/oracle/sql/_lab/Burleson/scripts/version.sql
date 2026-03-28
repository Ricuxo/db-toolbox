/*  */
create or replace function return_version
return varchar2 as
cursor get_version is
select banner from v$version 
where banner like '% 7.%' or
banner like '% 8.%';

version varchar2(64);
short_version varchar2(9);

begin
open get_version;
fetch get_version into version;
short_version:=substr(version,24,9);
return short_version;
end;
