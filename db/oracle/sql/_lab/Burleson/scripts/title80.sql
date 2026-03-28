/*  */
rem
rem TITLE80.SQL 
rem
rem FUNCTION:    This SQL*Plus script builds a standard report heading 
rem              heading for database reports that are 80 columns 
rem
column  TODAY     NEW_VALUE    CURRENT_DATE   NOPRINT
column  TIME      NEW_VALUE    CURRENT_TIME   NOPRINT
column  DATABASE  NEW_VALUE    DATA_BASE      NOPRINT
column  PASSOUT   NEW_VALUE    DBNAME         NOPRINT
rem
define COMPANY = " "
define HEADING = "&1"
rem
set lines 75
TTITLE LEFT "Date: " current_date CENTER company col 66 "Page:" format 999 -
       SQL.PNO SKIP 1 LEFT "Time: " current_time CENTER heading RIGHT -
       format a15 SQL.USER SKIP 1 CENTER format a20 data_base SKIP 2
rem
rem
set heading off
set pagesize 0
rem
set termout off
SELECT TO_CHAR(SYSDATE,'MM/DD/YY') TODAY,
      TO_CHAR(SYSDATE,'HH:MI AM') TIME,
      value||' database ' DATABASE, 
      rtrim(value) passout
FROM   v$parameter
where name = 'db_name';
rem
set termout on
set heading on
set pagesize 58
set newpage 0
DEFINE DB = '&DBNAME'

