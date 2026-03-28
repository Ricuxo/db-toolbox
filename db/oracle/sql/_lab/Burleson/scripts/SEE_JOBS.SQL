/*  */
column what format a35 heading 'Job Content'
column job format 99999 heading 'Job #'
column next_date format a15 heading 'Next Date'
column last_date format a15 heading 'Last Date'
column interval format a20 heading 'Interval'
column broken format a5 heading 'Broke?'
column failures heading 'Failures'
set lines 132
@title132 'Current Job Status'
spool rep_out\&db\see_jobs
select 
	job,
	what,
	failures,
	to_char(next_date,'dd-mon-yy hh24:mi') next_date,
        to_char(last_date,'dd-mon-yy hh24:mi') last_date,
        interval,
	decode(broken,'N','No','Y','Yes',broken) broken 
from 
	dba_jobs
/
spool off
ttitle off

