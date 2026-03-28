/*  */
ALTER SESSION SET NLS_DATE_FORMAT="yyyymmddhhmiss";
/*
||  Script Name:		data.sql
||  Author:		Ramesh K Meda
||  Date:		Feb 1995 (Does day matter?)
||    info:	Feel free to copy!
||  Fees:		As you please!
*/
clear columns
column NAME format A64                                                                              
column VALUE format S00000000000000000000000000000000000000.00000                                   
column REP_ORDER format S00000000000000000000000000000000000000.00000                               
set linesize 169                                                                                    
set echo off
set pagesize 0
set space 0
set feedback off
set verify off
set pause off
set termout off
spool dba_temp.dat
select
   NAME                           ,'|'                                                              
,  VALUE                          ,'|'                                                              
,  REP_ORDER                      ,'|'                                                              
from dba_temp;
spool off
set pagesize 15
set feedback on
set verify on
set heading on
set linesize 80
set termout on
