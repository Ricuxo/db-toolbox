/*  */
REM
REM     Name:      tab_rep.sql
REM     FUNCTION:  Document table extended parameters
REM     Use:       From SQLPLUS 
REM	MRA 6/13/97 Created for ORACLE8
REM
column owner 		format a10 heading 'Owner'
column table_name 	format a15 heading 'Table'
column tablespace_name 	format a13 heading 'Tablespace'
column table_type_owner format a10 heading 'Type|Owner'
column table_type 	format a13 heading 'Type'
column iot_name 	format a10 heading 'IOT|Overflow'
column iot_type 	format a12 heading 'IOT or|Overflow'
COLUMN nested 		format a6  heading 'Nested'
undef owner
set lines 130 verify off feedback off pages 58
start title132 'Extended Table Report'
spool rep_out\&&db\ext_tab.lis
select
	OWNER,                          
	TABLE_NAME,                     
	TABLESPACE_NAME,                              
	IOT_NAME,                       
	LOGGING,                                      
	PARTITIONED,                    
	IOT_TYPE,
        'N/A' table_type_owner,
        'N/A' table_type,                       
	TEMPORARY,                      
	NESTED 
from 
	dba_tables 
where 
	(owner like upper('%&&owner%') and owner not in ('SYS','SYSTEM'))    
UNION 
select
	OWNER,                          
	TABLE_NAME,                     
	TABLESPACE_NAME,                              
	IOT_NAME,                       
	LOGGING,                                      
	PARTITIONED,                    
	IOT_TYPE,                       
	TABLE_TYPE_OWNER,               
	TABLE_TYPE,                                     
	TEMPORARY,                      
	NESTED 
from 
	dba_object_tables 
where 
	(owner like upper('%&&owner%') and owner not in ('SYS','SYSTEM')) ;           
spool off
set verify on lines 80 pages 22 feedback on
ttitle off
undef owner
clear columns
