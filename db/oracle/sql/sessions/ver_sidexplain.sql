SET pages 2000
SET lin 150
ALTER SESSION SET statistics_level=ALL;

variable SQLID VARCHAR2(20);

begin
  select sql_id into :SQLID from v$session where sid=&&sid;
end;
.
/

SELECT * FROM TABLE (DBMS_XPLAN.display_cursor (:SQLID));

UNDEFINE SID
UNDEFINE SQLID 