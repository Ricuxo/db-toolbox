/*  */
col owner heading 'Owner'
col cons_type heading 'Constraint Type'
col num heading 'Number'
start title80 'Constraint Breakdown'
spool rep_out\&&db\cons_bd
select 
  owner 
  ,decode(constraint_type,'U','Unique','R','Foreign Key','P','Primary Key','C','Check','Other') cons_type
  ,count(*) num
from 
  dba_constraints 
group by owner, decode(constraint_type,'U','Unique','R','Foreign Key','P','Primary Key','C','Check','Other')
/
spool off
clear columns
ttitle off
