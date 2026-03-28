SET pages 2000
SET lin 150
ALTER SESSION SET statistics_level=ALL;

SELECT * FROM table(DBMS_XPLAN.DISPLAY_AWR('&sql_id'));
