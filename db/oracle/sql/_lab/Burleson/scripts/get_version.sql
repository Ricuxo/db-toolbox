/*  */
create or replace FUNCTION return_version
RETURN varchar2 AS
 CURSOR get_version IS
  SELECT banner FROM v$version
  WHERE
                   banner LIKE '% 7.%'
                OR banner LIKE '% 8.%'
                OR banner LIKE '% 9.%'
                OR banner LIKE '% 10.%';
 version   VARCHAR2(64);
 short_version  VARCHAR2(9);
 pos integer;
BEGIN
  OPEN get_version;
  FETCH get_version INTO version;
  pos:=instr(version,'.');
  short_version:=SUBSTR(version,pos-1,9);
  RETURN short_version;
END;
