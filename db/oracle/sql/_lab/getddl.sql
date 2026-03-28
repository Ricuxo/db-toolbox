set long 999000
set tab on
set trim on
set trimspool on
set pagesize 0
set linesize 160
select dbms_metadata.get_ddl('&DDLTYPE','&DDLNAME','&OWNER')
  from dual
  /
