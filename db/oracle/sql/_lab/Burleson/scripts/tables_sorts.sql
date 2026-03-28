/*  */
col name heading 'Statistic'
col value heading 'Value'
@title80 'Table and Sort Stats'
spool rep_out\&db\tables_sorts
select name,value from v$sysstat where name like 'table%' or name like 'sort%';
spool off
clear columns
ttitle off
