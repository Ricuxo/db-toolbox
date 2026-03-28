/*  */
rem  **************************************************************************
rem  NAME: rowsize.sql     
rem  NOTES:        Currently requires DBA.
rem  INPUTS:
rem         tname  = Name of table.
rem         towner = Name of owner of table.
rem	    cfile  = Name of output SQL Script file
rem  **************************************************************************
column dum1  	noprint
column rsize 	format 99,999.99
column rcount 	format 999,999,999 newline 
accept tname  	prompt 'Enter table name: '
accept towner 	prompt 'Enter owner name: '
accept cfile  	prompt 'Enter name for output SQL script file: '
set pagesize 999  heading off  verify off  termout off
set feedback off  sqlcase upper  newpage 3
spool rep_out\&db\&cfile..sql
select 0 dum1,
       'select ''Table '||'&towner..&tname'||
      ' has '',count(*) rcount,'' rows of '', ('   from dual
union
select column_id,
      'sum(nvl(vsize('||column_name||'),0)) + 1 +'  from dba_tab_columns 
 where table_name = '&tname' and owner = '&towner'
   and column_id <> (select max(column_id)
                     from dba_tab_columns
		    where table_name = '&tname'
		      and owner = '&towner')
union
select column_id,
      'sum(nvl(vsize('||column_name||'),0)) + 1)'
  from dba_tab_columns 
 where table_name = '&tname' and owner = '&towner'
   and column_id = (select max(column_id)
                     from dba_tab_columns
		    where table_name = '&tname'
		      and owner = '&towner')
union 
select 997,  '/ count(*) + 5 rsize, '' bytes each.'''  from dual
union 
select 999,  'from &towner..&tname.;'  from dual;
spool off
set termout on  feedback on   pagesize 20   sqlcase mixed   newpage 1
start &cfile
clear columns
undef cfile
undef tname
undef towner
set verify on heading on
