--#####################################################################################################################################
--
-- Script Name:    Cust_Dbinfo.sql
-- Create Date:    January 2001
-- Script Version: 2.0
-- Author:         David Hansen,  Quest Software Professional Services
-- Revised:        Aug 13/03
-- Revisions Made:  1) Added new columns to chained row select
--                  2) Added select for nonBasic datatypes.
--                  3) Removed count of sequences per schema as it was a redundant select
--                  4) Removed individual used and free tablespace selects
--                  5) Added new tablespace select to combine total, used and unused in one select.  Improved performance.
--                  6) Added timing for total script time.
--                  7) Added timings for individual selects.
--                  8) Removed individual datafiles/sizing select.  It's now included in the new tablespace select statement.
--                  9) Added total size of datafiles statement.
--
-- Revised:        Sept 25/03
-- Revisions Made:  1) Removed Total Space sum for datafiles.  Formula was giving inconsistent results
--
-- Revised:        December 31/03
-- Revisions Made:  1) Modified partition sql to pull from dba_tab_partitions to list more partion info including chaining
--                  2) added 3 sql statements to find out information about user defined datatypes.  The third selects from 
--                     dba_type_versions which is only available in Oracle 9i.   This sql will fail on 8i instances but it is 
--                     in here to allow for keeping only one version of this script.
--                  3) changed linesize to 300 to allow for easier to read formatting of the information.
--
-- Revised:         Jan 21-26/04
-- Revisions Made:  1) Separated the queries for long and lob for efficiency.
--                  2) DBA_LOBS is now queried to find info about lobs including chunk size and in row.
--                  3) Added a compute sum to tablespace info so information does not have to be interpreted outside of the report.
--                  4) Modified the statement level trigger query to display more detailed information than just a count.
--                  5) Modified the redo log size query to display the value in megabytes for readability.
--                  6) Added a PL/SQL block to Calculate average redo switches and volumes
--                  7) Added a query to highlight and validate the log_parallelism parameter
--                  8) Added a query to highlight and validate the recovery_parallelism parameter
--                  9) Added float as a basic datatype. (float has been supported for years)
--                 10) Added query for bitmap indexes.
--
-- Revised:         June 24-28/04
-- Revisions Made:  1) replaced the 3 UDT queries with one simple query that pulls out information about UDTs with nested arrays.
--                  2) added a query for on delete cascades.
--                  3) added a query to find tables with more than 254 columns.
--
-- Revised:         July 24-28/04
-- Revisions Made:  1) added prompt for SID to appropriately name output file
--
--
-- Revised:         March 31/05
-- Revisions Made:  1) added schemas XDB and MSYS to where owner not in clauses to limit information
--                  2) added query to check for supplemental logging
--                  3) added owner to the query for tables created withing the last 90 days.
--                  
--
--#####################################################################################################################################

PROMPT

accept CUSTSID prompt 'Please enter the SID or Database Name (only used to name the output file):'
set verify off;
set timing off;
set feedback off;
set linesize 300;
set pagesize 1000;
timing start 'Total Duration';
spool &CUSTSID;

set heading off;
select '********************************************************' from dual;
select '****| Report for Database ' ||upper(substr(name,1,10)) || ' on ' ||substr(to_char(Sysdate,'dd-MON-rr hh:mi:ss'),1,15)|| '  |****' from v$database;
select '****| Oracle version ' ||substr(version,1,10)|| ' on Server ' ||upper(substr(host_name,1,15))|| '    |****' from v$instance;
select '****| Database is in ' ||substr(log_mode,1,20)|| ' mode                |****' from v$database;
select '****| Database created since ' ||substr(to_char(created,'dd-MON-rr hh:mi:ss'),1,20)|| '     |****' from v$database;
select '****| Database running since ' ||substr(to_char(startup_time,'dd-MON-rr hh:mi:ss'),1,20)|| '     |****' from v$instance;
select '********************************************************' from dual;

set heading off;
select '******************************************************' from dual;
select '****       Supplemental Logging                   ****' from dual;
select '******************************************************' from dual;

set heading on;
timing start 'SuppLog';

select lpad(a.SUPPLEMENTAL_LOG_DATA_MIN,7) as Minimal,lpad(a.SUPPLEMENTAL_LOG_DATA_PK,7) as PrimKey,lpad(a.SUPPLEMENTAL_LOG_DATA_UI,7) as UniIndx from v$database a;

timing stop 'SuppLog';

set heading off;
select '******************************************************' from dual;
select '****       List of Objects by Schema Owner        ****' from dual;
select '******************************************************' from dual;

set heading on;
timing start 'Schema Obj';
col username for a20

select   USERNAME,
         substr(count(decode(o.TYPE#, 2,o.OBJ#,'')),1,5) as Tabs,
         substr(count(decode(o.TYPE#, 1,o.OBJ#,'')),1,5) as Indx,
         substr(count(decode(o.TYPE#, 5,o.OBJ#,'')),1,5) as Syns,
         substr(count(decode(o.TYPE#, 4,o.OBJ#,'')),1,5) as Views,
         substr(count(decode(o.TYPE#, 6,o.OBJ#,'')),1,5) as Seqs,
         substr(count(decode(o.TYPE#, 7,o.OBJ#,'')),1,5) as Procs,
         substr(count(decode(o.TYPE#, 8,o.OBJ#,'')),1,5) as Funcs,
         substr(count(decode(o.TYPE#, 9,o.OBJ#,'')),1,5) as Pkgs,
         substr(count(decode(o.TYPE#,12,o.OBJ#,'')),1,5) as Trigs,
         substr(count(decode(o.TYPE#,10,o.OBJ#,'')),1,5) as Deps
from     sys.obj$ o, dba_users u
where    u.USER_ID = o.OWNER# (+)
and      o.TYPE# is NOT NULL
and      u.username not in ('SYS','SYSTEM','OUTLN','XDB','WMSYS')
group by USERNAME
order by USERNAME;
timing stop 'Schema Obj';

set heading off;
select '************************************************************' from dual;
select '****     List of Tables with more than 254 columns      ****' from dual;
select '************************************************************' from dual;
timing start '254ormore';

set heading on;

select owner,table_name,count(table_name) as "NumCols" from dba_tab_columns where owner not in ('SYS','SYSTEM','OUTLN','XDB','WMSYS') group by owner,table_name having count(table_name) > 254;
timing stop '254ormore';

set heading off;
select '************************************************************' from dual;
select '**** List of Tables that contain LONG data types        ****' from dual;
select '************************************************************' from dual;
timing start 'Long Lob';

set heading on;
select owner,table_name,column_name,data_type from dba_tab_columns where data_type in ('LONG') 
and owner not in ('SYS','SYSTEM','OUTLN','XDB','WMSYS');
timing stop 'Long Lob';

set heading off;
select '************************************************************' from dual;
select '****      List LOB table, columns and definitions        ****' from dual;
select '************************************************************' from dual;
timing start 'Lobdef';

set heading on;
col Owner for a20;
col Table for a35;
col column for a61;
select substr(owner,1,20) as "Owner",substr(table_name,1,30) as "Table",substr(column_name,1,60) as "Column",chunk,lpad(in_row,8) as "In Row" from dba_lobs where owner not in ('SYS','SYSTEM','OUTLN','XDB','WMSYS');
timing stop 'Lobdef';


set heading off;
select '********************************************************' from dual;
select '**** List of Partitioned Tables and their Partitions ****' from dual;
select '********************************************************' from dual;
timing start Partitons;

set heading on;
select table_owner,table_name, partition_name,subpartition_count,num_rows, blocks, empty_blocks, avg_space, chain_cnt, avg_row_len, 
       last_analyzed from DBA_TAB_PARTITIONS where table_owner not in ('SYS','SYSTEM','OUTLN','XDB','WMSYS');
timing stop Partitions;

set heading off;
select '******************************************************' from dual;
select '****       Listing of Index Organized Tables      ****' from dual;
select '******************************************************' from dual;
timing start IOTs;

set heading on;
select owner,table_name,iot_type from dba_tables where iot_type = 'IOT' and owner not in ('SYS','SYSTEM','OUTLN','XDB','WMSYS');

timing stop IOTs;

set heading off;
select '******************************************************' from dual;
select '****          Listing of Bitmap Indexes           ****' from dual;
select '******************************************************' from dual;
timing start Bitmaps;

set heading on;
select owner,index_name,table_owner,table_name from dba_indexes where index_type = 'BITMAP';

timing stop Bitmaps;

set heading off;
select '******************************************************' from dual;
select '**** List of Data Types Contained in the Database ****' from dual;
select '******************************************************' from dual;
timing start Datatypes;

set heading on;
select distinct data_type from dba_tab_columns where owner not in ('SYS','SYSTEM','OUTLN','XDB','WMSYS');

timing stop Datatypes;

set heading off;
select '**************************************************************' from dual;
select '**** List of non-basic Data Types Contained in the Database ****' from dual;
select '**************************************************************' from dual;
timing start 'NonBasic Datatypes';

set heading on;
select a.owner, a.table_name, a.column_name,a.data_type from dba_tab_columns a, dba_objects b
where data_type not in ('VARCHAR','VARCHAR2','DATE','NUMBER','LONG VARCHAR','LOB','BLOB','CLOB','LONG','LONG RAW','CHAR','ROWID','RAW','FLOAT') and
a.owner not in ('SYS','SYSTEM','OUTLN','XDB','WMSYS')
and a.table_name = b.object_name
and b.object_type = 'TABLE';

timing stop 'NonBasic Datatypes';

set heading off;
select '**************************************************************' from dual;
select '****                  List of Nested Arrays               ****' from dual;
select '**************************************************************' from dual;
timing start 'NestArray';

Set heading on;
select b.owner,b.attr_type_name as "Nested Array", b.type_name as "Nested In Type", b.attr_name as "Nested in Column"  from dba_type_attrs b where b.attr_type_name in (select a.type_name from dba_types a where a.owner not in ('SYS','SYSTEM','OUTLN','MDSYS','CTXSYS','ORDSYS','XDB','WMSYS') and typecode = 'COLLECTION');

timing stop 'NestArray';


set heading off;
select '********************************************************' from dual;
select '**** List of Tables with more than 500 Chained Rows ****' from dual;
select '********************************************************' from dual;
timing start Chaining;

Set heading on;
select owner,table_name,num_rows,chain_cnt,empty_blocks, avg_row_len, last_analyzed, row_movement, buffer_pool,iot_type from dba_tables where chain_cnt > 500 and owner not in ('SYS','SYSTEM','OUTLN','XDB','WMSYS');

timing stop Chaining;
set heading off;
select '********************************************************' from dual;
select '****         List of Analyzed dates 90 days         ****' from dual;
select '********************************************************' from dual;
timing start Analyzed;

set heading on;
select distinct(to_char(last_analyzed,'DD-MON-RR')) as "Analyzed" from dba_tables where last_analyzed is not NULL and
last_analyzed > sysdate-90 and rownum < 20 order by "Analyzed";

timing stop Analyzed;
set heading off;
select '********************************************************' from dual;
select '****    List of Tables Created in the last 60 Days  ****' from dual;
select '********************************************************' from dual;
timing start Created;

set heading on;
col "Table_Nm" for a30;
select owner, substr(object_name,1,30) as "Table_Nm",created from dba_objects where object_type = 'TABLE' and created > sysdate-60 and owner not in ('SYS','SYSTEM','OUTLN','XDB','WMSYS');


timing stop Created;
set heading off;
select '*****************************************************************' from dual;
select '**** Count of triggers by Row Level and then Statement Level ****' from dual;
select '*****************************************************************' from dual;
timing start Triggers;

set heading on;
select count(trigger_type) as "Row Level" from dba_triggers where trigger_type like '%ROW%' and owner not in ('SYS','SYSTEM','OUTLN','XDB','WMSYS');

set heading off;
select '**** Statement Level ****' from dual;
set heading on;
select owner,trigger_name,trigger_type,table_owner,table_name from dba_triggers where trigger_type not like '%ROW%' and owner not in ('SYS','SYSTEM','OUTLN','XDB','WMSYS');

timing stop Triggers;


set heading off;
select '******************************************************' from dual;
select '****   List Constraints with On-Delete Cascades   ****' from dual;
select '******************************************************' from dual;

timing start OnDelCasc;
set heading on;

select owner,constraint_name from dba_constraints where delete_rule = 'CASCADE'
and owner not in ('SYS','SYSTEM','OUTLN','XDB','WMSYS');

timing stop OnDelCasc;


set heading off;
select '******************************************************' from dual;
select '****              Tablespace Info                 ****' from dual;
select '******************************************************' from dual;
timing start 'Tablespace Info';

set heading on;



set heading on;
break on report
compute sum of "total MB" on report
col "total MB" format 999,999,999,999,990
compute sum of "Free MB" on report
col "Free MB" format 999,999,999,999,990
compute sum of "Used MB" on report
col "Used MB" format 999,999,999,999,990


select
 d.tablespace_name, 
 SUBSTR(d.file_name,1,50) "Datafile name",
 ROUND(MAX(d.bytes)/1024/1024,2) as "total MB", 
 DECODE(SUM(f.bytes), null, 0, ROUND(SUM(f.Bytes)/1024/1024,2)) as "Free MB" , 
 DECODE( SUM(f.Bytes), null, 0, ROUND((MAX(d.bytes)/1024/1024) - (SUM(f.bytes)/1024/1024),2)) as "Used MB" 
from 
  DBA_FREE_SPACE f , DBA_DATA_FILES d 
where 
 f.tablespace_name(+) = d.tablespace_name 
 and f.file_id(+) = d.file_id
group by 
d.tablespace_name,d.file_name;

clear breaks

timing stop 'Tablespace Info';



set heading off;
select '*********************************************************' from dual;
select '****      List of Locally Managed Tablespaces        ****' from dual;
select '*********************************************************' from dual;
timing start LMTs;

set heading on;
col Tablespace for a15;

select substr(tablespace_name,1,15) as "TableSpace",initial_extent,next_extent,status,contents,logging,extent_management,allocation_type,plugged_in 
from dba_tablespaces where extent_management = 'LOCAL';

timing stop LMTs;

set heading off;
select '******************************************************' from dual;
select '****           Redo Log Files and Sizing          ****' from dual;
select '******************************************************' from dual;
timing start 'Redo Sizing';

set heading on;
col "File Name" for a80;
col "Size in MB" format 999,999,999,999,990
select substr(a.member,1,80) as "File Name",b.bytes/1024/1024 as "Size in MB" from v$logfile a,v$log b where a.group#=b.group#;
timing stop 'Redo Sizing';

set heading off;
select '******************************************************' from dual;
select '****     Redolog Switch Rate by Date and Hour     ****' from dual;
select '******************************************************' from dual;
timing start Redo;
set heading on;
col Total for a5;
col h00 for a3;
col h01 for a3;
col h02 for a3;
col h03 for a3;
col h04 for a3;
col h05 for a3;
col h06 for a3;
col h07 for a3;
col h08 for a3;
col h09 for a3;
col h10 for a3;
col h11 for a3;
col h12 for a3;
col h13 for a3;
col h14 for a3;
col h15 for a3;
col h16 for a3;
col h17 for a3;
col h18 for a3;
col h19 for a3;
col h20 for a3;
col h21 for a3;
col h22 for a3;
col h23 for a3;
col h24 for a3;


break on report
compute max of "Total" on report
compute max of "h00" on report
compute max of "h01" on report
compute max of "h02" on report
compute max of "h03" on report
compute max of "h04" on report
compute max of "h05" on report
compute max of "h06" on report
compute max of "h07" on report
compute max of "h08" on report
compute max of "h09" on report
compute max of "h10" on report
compute max of "h11" on report
compute max of "h12" on report
compute max of "h13" on report
compute max of "h14" on report
compute max of "h15" on report
compute max of "h16" on report
compute max of "h17" on report
compute max of "h18" on report
compute max of "h19" on report
compute max of "h20" on report
compute max of "h21" on report
compute max of "h22" on report
compute max of "h23" on report

SELECT  trunc(first_time) "Date",
        to_char(first_time, 'Dy') "Day",
        substr(count(1),1,5) as "Total",
        substr(SUM(decode(to_char(first_time, 'hh24'),'00',1,0)),1,3) as "h00",
        substr(SUM(decode(to_char(first_time, 'hh24'),'01',1,0)),1,3) as "h01",
        substr(SUM(decode(to_char(first_time, 'hh24'),'02',1,0)),1,3) as "h02",
        substr(SUM(decode(to_char(first_time, 'hh24'),'03',1,0)),1,3) as "h03",
        substr(SUM(decode(to_char(first_time, 'hh24'),'04',1,0)),1,3) as "h04",
        substr(SUM(decode(to_char(first_time, 'hh24'),'05',1,0)),1,3) as "h05",
        substr(SUM(decode(to_char(first_time, 'hh24'),'06',1,0)),1,3) as "h06",
        substr(SUM(decode(to_char(first_time, 'hh24'),'07',1,0)),1,3) as "h07",
        substr(SUM(decode(to_char(first_time, 'hh24'),'08',1,0)),1,3) as "h08",
        substr(SUM(decode(to_char(first_time, 'hh24'),'09',1,0)),1,3) as "h09",
        substr(SUM(decode(to_char(first_time, 'hh24'),'10',1,0)),1,3) as "h10",
        substr(SUM(decode(to_char(first_time, 'hh24'),'11',1,0)),1,3) as "h11",
        substr(SUM(decode(to_char(first_time, 'hh24'),'12',1,0)),1,3) as "h12",
        substr(SUM(decode(to_char(first_time, 'hh24'),'13',1,0)),1,3) as "h13",
        substr(SUM(decode(to_char(first_time, 'hh24'),'14',1,0)),1,3) as "h14",
        substr(SUM(decode(to_char(first_time, 'hh24'),'15',1,0)),1,3) as "h15",
        substr(SUM(decode(to_char(first_time, 'hh24'),'16',1,0)),1,3) as "h16",
        substr(SUM(decode(to_char(first_time, 'hh24'),'17',1,0)),1,3) as "h17",
        substr(SUM(decode(to_char(first_time, 'hh24'),'18',1,0)),1,3) as "h18",
        substr(SUM(decode(to_char(first_time, 'hh24'),'19',1,0)),1,3) as "h19",
        substr(SUM(decode(to_char(first_time, 'hh24'),'20',1,0)),1,3) as "h20",
        substr(SUM(decode(to_char(first_time, 'hh24'),'21',1,0)),1,3) as "h21",
        substr(SUM(decode(to_char(first_time, 'hh24'),'22',1,0)),1,3) as "h22",
        substr(SUM(decode(to_char(first_time, 'hh24'),'23',1,0)),1,3) as "h23"
FROM    V$log_history
group by trunc(first_time), to_char(first_time, 'Dy')
Order by 1;

clear breaks
timing stop Redo;


set heading off;
select '******************************************************' from dual;
select '****  Redolog Daily and Hourly volume calculated  ****' from dual;
select '******************************************************' from dual;

timing start Redovol;


--#######################################################################################
--##           PL/SQL used here to gather and display average redo volumes             ##
--#######################################################################################

set serveroutput on;
declare

v_log    number;
v_days   number;
v_logsz  number;
v_adsw   number;
V_advol  number;
v_ahsw   number;
v_ahvol  number;


begin

select count(first_time) into v_log from v$log_history;
select count(distinct(to_char(first_time,'dd-mon-rrrr'))) into v_days from v$log_history;
select max(bytes)/1024/1024 into v_logsz from v$log;

v_adsw := round(v_log / v_days);
v_advol := round(v_adsw * v_logsz);
v_ahsw := round(v_adsw / 24);
v_ahvol := round((v_adsw / 24 )) * v_logsz;

dbms_output.put ('Total Switches' || ' '||v_log||'  ==>  ');
dbms_output.put ('Total Days' || ' '|| v_days||'  ==>  ');
dbms_output.put_line ('Redo Size' || ' ' || v_logsz);
dbms_output.put ('Avg Daily Switches' || ' ' || v_adsw||'  ==>  ');
dbms_output.put_line ('Avg Daily Volume in Meg' || ' ' || v_advol);
dbms_output.put ('Avg Hourly Switches' || ' ' || v_ahsw||'  ==>  ');
dbms_output.put_line ('Avg Hourly Volume in Meg' || ' ' || v_ahvol);


end;

/

--#######################################################################################
--##                                                  END of PL/SQL routine            ##
--#######################################################################################



timing stop Redovol;


set heading off;
select '******************************************************' from dual;
select '****      Rollback Segment Sizing Statistics      ****' from dual;
select '******************************************************' from dual;
timing start Rollback;

set heading on;
col Name for a20;

select substr(a.segment_name,1,20) as "Name", a.initial_extent,a.next_extent,b.OPTSIZE,a.status,b.shrinks  from dba_rollback_segs a,v$rollstat b
where a.SEGMENT_ID = b.USN;

timing stop Rollback;
set heading off;

timing start Params;

select '******************************************************' from dual;
select '****          PARALLELISM Settings                ****' from dual;
select '******************************************************' from dual;

select decode(value,1,'LOG PARALLELISM OK','LOG PARALLELISM IS NOT 1') from v$parameter where name = 'log_parallelism';
select decode(value,0,'RECOVERY PARALLELISM OK','RECOVERY PARALLELISM IS NOT 0') from v$parameter where name = 'recovery_parallelism';


select '******************************************************' from dual;
select '****          Database Parameter Settings         ****' from dual;
select '******************************************************' from dual;
set heading on;
col Parameter for a35;
col Setting for a50;
select substr(name,1,35) as "Parameter", substr(value,1,50) as "Setting" from v$parameter order by name;

timing stop Params;
timing stop 'Total Duration';
spool off;
set verify on;