/*  */
REM Script for getting undocumented init.ora
REM parameters from a 7.3 or 8.0.2 instance
REM MRA - Revealnet 4/23/97
REM
column parameter format a40
column description format a25 word_wrapped
column "Instance Value" format a10 heading "Value"
set lines 80
set pages 1000
spool undoc.lis
select  
	a.ksppinm  "Parameter",  
	a.ksppdesc "Description", 
	c.ksppstvl "Instance Value"
from 
	x$ksppi a, 
	x$ksppsv c
where 
        a.indx = c.indx
	and a.ksppinm like '/_%' escape '/'
order by 1
/
spool off


