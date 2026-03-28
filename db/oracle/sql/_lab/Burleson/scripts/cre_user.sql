/*  */
create user &&user identified by &password
default tablespace &&default
temporary tablespace &temp
quota unlimited on &&default;
grant connect to &&user;
grant scopus_role to &&user;
undef user
undef default
