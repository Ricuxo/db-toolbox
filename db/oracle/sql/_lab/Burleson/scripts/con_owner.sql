/*  */
column constraint_type format a25 heading 'Constraint|Type'
column owner format a24 heading 'Constraint|Owner'
column num format 9,999 heading 'Number'
break on owner
set pages 54 lines 80 verify off feedback off
spool con_owner
ttitle 'Constraints by Owner'
select 
   owner, 
   decode(
          constraint_type, 'P','Primary Key',
          'R','Foreign Key',
          'C','Check',
          'U','Unique',
          'V','Enabled','Other') Constraint_type,
   count(*) Num
from dba_constraints
where owner not in ('SYS','SYSTEM','SCOTT','SYSMAN','ORDSYS','CTXSYS','ODM',
 'XDB','RMAN','ODSYS','CTXSYS','MDSYS','WKSYS','WMSYS')
group by 
     owner, decode(
          constraint_type, 'P','Primary Key',
          'R','Foreign Key',
          'C','Check',
          'U','Unique',
          'V','Enabled','Other')
/
spool off
set verify on feedback on
clear columns
clear breaks
ttitle off
