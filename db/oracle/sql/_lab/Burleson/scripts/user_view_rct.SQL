/*  */
REM
REM NAME        :view_rct.sql
REM FUNCTION:recreate database views by owner
REM USE         	:Generate a report on database views
REM Limitations :If your view definitions are greater than 5000 characters
REM              	 then increase the set long. This can be determined by
REM              	 querying the DBA_VIEWS table's text_length column for the
REM              	 max value: select max(text_length) from dba_views;
REM
set pages 59 lines 79 feedback off echo off verify off
define cr='chr(10)'
column text 		format a80 word_wrapped
column view_name 	format a20
column dbname new_value db noprint
undef owner_name
undef view_name
select value dbname from v$parameter where name='db_name';
set long 5000 heading off
spool rep_out\&db\cre_view.sql
select 
	'rem Code for view: '||v.view_name||'
CREATE OR REPLACE VIEW '||user||'.'||v.view_name||' as '||&&cr,
	v.text
from 
	user_views v 
where 
	view_name like upper('%&&view_name%')
;
spool off
set heading on pages 22 lines 80 feedback on echo on
clear columns
ttitle off
Pause Press enter to continue

