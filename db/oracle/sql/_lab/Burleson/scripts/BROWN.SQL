/*  */
rem  **************************************************************************
rem
rem  NAME: brown.sql
rem
rem  HISTORY:
rem  Date             Who              What
rem  --------  -------------------  ------------------------------------------
rem   06/05/97  Mike Ault	     Updated for Oracle 7.x
rem  FUNCTION:  Will show index browning for all indexes for a
rem	        user. 
rem  INPUTS:  owner = Table owner name.
rem  **************************************************************************

column value noprint new_value blocksize
define cr=chr(10)
define quote=chr(39)
select value from v$parameter where name='db_block_size';
#accept tab_owner prompt 'Enter Table Owner for Indexes:'
set heading off verify off termout off pages 0 recsep 0 feedback off
spool index_sz.sql
select 
        'drop table stat_temp;'||&&cr||
	'create table stat_temp as select * from index_stats;'||&&cr||
	'truncate table stat_temp;'  
from dual;
select	
	'analyze index '||index_name||
        ' validate structure;'||&&cr||
	'insert into stat_temp select * from index_stats;'||&&cr||
	'commit;'
from user_indexes;
spool off
set feedback on termout on lines 80
start index_sz.sql
insert into temp_size_table select name,trunc(used_space/&&blocksize)
from stat_temp;
rem drop table stat_temp;
clear columns
set lines 132 pages 55
column del_lf_rows_len format 999,999,999 heading 'Deleted Bytes'
column lf_rows_len format 999,999,999 heading 'Filled Bytes'
column browning format 999.90 heading 'Percent|Browned'
start title132 "Index Browning Report"
spool rep_out/&db/browning.lst
select 
	name,del_lf_rows_len,lf_rows_len,
	(del_lf_rows_len/decode((lf_rows_len+del_lf_rows_len),0,1,
       lf_rows_len+del_lf_rows_len))*100 browning
            , (LF_ROWS-DISTINCT_KEYS)*100/ decode(LF_ROWS,0,1,LF_ROWS) DISTINCTIVENESS 
from 
	stat_temp 
where 
	del_lf_rows_len>0;
spool off
