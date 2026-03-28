/*  */
rem
rem TITLE132.SQL 
rem
rem FUNCTION:    This SQL*Plus script builds a standard report heading 
rem              heading for database reports that are 132 columns 
rem
column  TODAY    NEW_VALUE  CURRENT_DATE   NOPRINT
column  TIME     NEW_VALUE  CURRENT_TIME   NOPRINT
column  DATABASE NEW_VALUE  DATA_BASE      NOPRINT
column  PASSOUT  NEW_VALUE  DBNAME         NOPRINT
rem
define COMPANY = " "
define HEADING = "&1"
rem
TTITLE LEFT "Date: " current_date CENTER company col 118 "Page:" format 999 -
       SQL.PNO SKIP 1 LEFT "Time: " current_time CENTER heading RIGHT -
       format a15 SQL.USER SKIP 1 CENTER format a20 data_base SKIP 2
rem
rem
set heading off termout off
rem
SELECT TO_CHAR(SYSDATE,'MM/DD/YY') TODAY,
      TO_CHAR(SYSDATE,'HH:MI AM') TIME,
      value||' database' DATABASE, 
      rtrim(value) passout
FROM   sys.v_$parameter
where name = 'db_name';
rem
set heading on termout on
set newpage 0
DEFINE DB = '&DBNAME'

