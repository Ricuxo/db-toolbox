/*  */
REM
REM     Name:      tab_iot.sql
REM     FUNCTION:  Document table extended parameters
REM     Use:       From SQLPLUS 
REM	MRA 6/13/97 Created for ORACLE8
REM
column owner 		format a10 heading 'Owner'
column table_name 	format a30 heading 'Table'
column tablespace_name 	format a20 heading 'Tablespace'
column iot_name 	format a26 heading 'IOT|Overflow'
column iot_type 	format a12 heading 'IOT or|Overflow'
undef owner
set lines 130 verify off feedback off pages 58
start title132 'IOT Table Report'
spool rep_out\&&db\iot_tab_&&owner.lis
select
	OWNER,                          
	TABLE_NAME,                     
	TABLESPACE_NAME,                              
	IOT_NAME,                       
	LOGGING,                                      
	PARTITIONED,                    
	IOT_TYPE
from 
	dba_tables 
where 
	owner like upper('%&&owner%')
        and iot_type is not null
UNION 
select
	OWNER,                          
	TABLE_NAME,                     
	TABLESPACE_NAME,                              
	IOT_NAME,                       
	LOGGING,                                      
	PARTITIONED,                    
	IOT_TYPE
from 
	dba_object_tables 
where 
	owner like upper('%&&owner%')
        and iot_type is not null;           
spool off
set verify on lines 80 pages 22 feedback on
ttitle off
undef owner
clear columns
