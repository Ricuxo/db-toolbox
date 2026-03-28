/*  */
rem *******************************************************************
rem  NAME: quota.sql     
rem  FUNCTION: Print the tablespace quotas of users. 
rem *******************************************************************
prompt Percent signs are wild cards
accept username prompt 'Enter user name or wild card '
prompt Print the details of the Users Tablespace Quotas
start title80 "Database Users Space Quotas by Tablespace"
col un 		format a25 		heading 'User Name'
col ta 		format a25 		heading 'Tablespace' 
col usd 		format 9,999,999 	heading 'K Used' 
col maxb  	format 9,999,999 	heading 'Max K ' 
set verify off feedback off newpage 0 heading on
spool rep_out\&db\tsquotas
break on ta skip 2
select 
 TABLESPACE_NAME  	ta,
 USERNAME    		un,
 BYTES/1024       		usd, 
 MAX_BYTES/1024   	maxb
from dba_ts_quotas
   where username = upper('&&username')
order by tablespace_name,username;
prompt End of Report
spool off
set verify on 
undef username
clear breaks
clear columns
clear computes
set verify on feedback on heading on
ttitle off
