/*  */
rem: Shows by user who has possible
rem: SQL reuse problems
column total_hash heading 'Total Hash|Values'
column same_hash heading 'SQL With|Same Hash'
column u_hash_ratio format 999.999 heading 'SQL Sharing|Hash'
start title80 'Shared Hash Value Report'
spool rep_out\&&db\shared_hash.lst
break on report
compute sum of total_hash on report 
compute sum of same_hash on report
select 
	a.username,
	count(b.hash_value) total_hash, 
	count(b.hash_value)-count(unique(b.hash_value)) same_hash,
	(count(unique(b.hash_value))/count(b.hash_value))*100 u_hash_ratio
from 
	dba_users a, 
	v$sqlarea b
where 
	a.user_id=b.parsing_user_id
group by 
	a.username
order by
      total_hash desc;
spool off
clear computes
