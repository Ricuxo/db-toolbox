/*  */
column parameter format a40
column value format a30
column ksppidf heading 'Is|Default'
set feedback off verify off pages 55
start title80 'Undocumented Init.ora Parameters'
spool rep_out/&db/undoc
select  KSPPINM "Parameter",
  KSPPIVL "Value",
  KSPPIDF
   from x$ksppi
where ksppinm like '/_%' escape '/'
/
spool off
ttitle off
