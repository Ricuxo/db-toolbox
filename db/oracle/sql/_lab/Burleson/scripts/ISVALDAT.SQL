/*  */
CREATE OR REPLACE FUNCTION IsValidDate (in_date varchar2, in_format varchar2)
RETURN INTEGER IS
rtn_code integer;
BEGIN
select to_date(in_date,in_format) from dual;
rtn_code:=0;
RETURN rtn_code;
EXCEPTION
When OTHER then
rtn_code:=1;
RETURN rtn_code;
END;
