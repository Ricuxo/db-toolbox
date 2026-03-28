/*  */
REM
REM NAME:      FPRC_RPT.SQL 
REM
REM FUNCTION: Build a script to re-create functions, procedures, 
REM           packages or package bodies.
REM
REM
set termout off verify off feedback off lines 1000 pages 0 heading off
set recsep off space 0
column text format a1000 word_wrap
column line noprint
select 'create or replace '||text,line
from 
	dba_source
where
	owner = upper('&&1') and
	type = upper('&&2') and
	name = upper('&&3') and
	line = 1;
select text,line 
from
	dba_OBJECTS s1,
	dba_source s2
where
	s1.OBJECT_type = upper('&&2') and
	s1.owner = upper('&&1') and
	s1.object_name = upper('&&3') and
	s1.OBJECT_type = s2.type and
	s1.owner = s2.owner and
	s1.OBJECT_NAME = s2.name and
	line > 1
order by
	2;
select '/' from dual;
