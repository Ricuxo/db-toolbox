/*  */
REM Script for getting undocumented init.ora
REM parameters from a 7.3 or 8.0.2 instance
REM MRA - Revealnet 4/23/97
REM
column parameter format a37
column description format a30 word_wrapped
column "Session Value" format a10
column "Instance Value" format a10
set lines 100
set pages 1000
start title132 'Undocumented Parameters'
spool rep_out\&db\undoc
select  
	a.ksppinm  "Parameter",  
	a.ksppdesc "Description", 
	b.ksppstvl "Session Value",
	c.ksppstvl "Instance Value"
from 
	x$ksppi a, 
	x$ksppcv b, 
	x$ksppsv c
where 
	a.indx = b.indx 
	and a.indx = c.indx
	and a.ksppinm like '/_%' escape '/'
order by 1
/
spool off
ttitle off

