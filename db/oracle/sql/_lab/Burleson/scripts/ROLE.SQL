/*  */
REM NAME        : ROLE.SQL
REM FUNCTION    : GENERATE ROLES REPORT
REM USE         : manual
REM Limitations : None
REM
set pages 58
column role         format a19 heading 'User or Role'
column admin_option format a3  heading 'Ad?'
column owner        format a7 heading 'Owner'
column table_name   format a26 heading 'Table name'
column privilege    format a21 heading 'Priv, Grant or Role'
column r_ord noprint
break on role
start titel132 'ORACLE ROLES REPORT'
define output = 'rep_out\&db\role_rpt'
spool &output
select 
  2 r_ord, b.role role, b.owner owner, b.table_name,
  b.privilege privilege, b.grantable admin_option
from 
  sys.role_tab_privs b
union
select 
  1 r_ord, a.role role, 'N/A' owner, 'N/A' table_name, 
  a.privilege privilege, a.admin_option admin_option 
from 
  sys.role_sys_privs a
union
select 
  3 r_ord, c.role role, 'N/A' owner, 'N/A' table_name, 
  c.granted_role privilege, c.admin_option admin_option
from 
   sys.role_role_privs c
order by 
   role,r_ord;
spool off
set flush on term on pagesize 22  linesize 80
clear columns
clear breaks
ttitle off
pause Press enter to continue

