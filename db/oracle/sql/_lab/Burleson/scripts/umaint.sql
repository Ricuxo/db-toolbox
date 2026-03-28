/*  */
create or replace package umaint as
    procedure save_pass (uname in dba_users.username%type);
    procedure change_pass (uname in dba_users.username%type,
                           passwd in dba_users.password%type);
    procedure reset_pass (uname in dba_users.username%type);
    procedure prt_mess (mess_text varchar2);

    old_pass  dba_users.password%type := null;
end umaint;
/

create or replace package body umaint as

procedure save_pass (uname in dba_users.username%type) is

cursor get_pass is
       select du.password 
       from   dba_users du
       where  du.username = upper(uname);
begin
  open get_pass;
  fetch get_pass into old_pass;
  close get_pass;
exception
  when others then
    prt_mess('ERROR: Unable to save password for user '||uname);
end;

procedure change_pass (uname in dba_users.username%type,
                       passwd in dba_users.password%type) is
  c_pass_set integer;
  r_pass_set integer;

begin
  save_pass(uname);
  c_pass_set := dbms_sql.open_cursor;
  dbms_sql.parse(c_pass_set,'alter user '||uname||' identified by '||passwd, dbms_sql.native); 
  r_pass_set := dbms_sql.execute(c_pass_set);
  dbms_sql.close_cursor(c_pass_set);
  prt_mess('Password successfully changed for user '||uname);
exception
  when others then
    prt_mess('ERROR: Unable to change password for user '||uname);
end;

procedure reset_pass (uname in dba_users.username%type) is

begin
  if old_pass is null then
     prt_mess('ERROR: No saved password for user '||uname);
   else
     change_pass(uname,'values '''||old_pass||'''');
  end if;
end;

procedure prt_mess (mess_text in varchar2) is

begin
  dbms_output.put_line(' ');
  dbms_output.put_line(mess_text);
  dbms_output.put_line(' ');
end;

end umaint;
/
