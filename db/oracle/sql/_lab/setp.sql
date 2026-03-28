--
-- Define SQLPROMPT
--
set linesize 200
set pagesize 1000
set termout off
define ret='SQL'
column ret new_value ret noprint
select lower(host_name)||'@'||lower(name)||':'||lower(user) ret
  from v$database, v$instance;
set sqlprompt '&&ret> '
set termout on
--clear screen

