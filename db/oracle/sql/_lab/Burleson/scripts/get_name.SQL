/*  */
undef name
column firstname format a10
column lastname format a10
select firstname,lastname,phone,extension from users a, profiles b
where b.login_name='&name' and
a.userid=b.userid
/
