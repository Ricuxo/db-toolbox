/*  */
col owner format a15 heading 'Object Owner'
col type heading 'Object Type'
col num1 format 9,999,999 heading 'Times|FORALL|Used'
col num2 format 9,999,999 heading 'Times|BULD BIND|Used'
col num3 format 9,999,999 heading 'Times|NOCOPY|Used'
@title80 'New PL/SQL Feature Usage' 
spool rep_out\&db\new_pl_feat
select a.owner, a.type,count(a.text) num1, count(NULL) num2, count(NULL) num3 
from 
    dba_source a
where
     upper(a.text) like '%FORALL%'
group by a.owner, a.type
union
select b.owner, b.type,count(null) num1, count(b.text) num2, count(NULL) num3 
from 
    dba_source b
where
     upper(b.text) like '%BULK%'
group by b.owner, b.type
UNION
select c.owner, c.type,count(null) num1, count(null) num2, count(c.text) num3 
from 
     dba_source c
where
     upper(c.text) like '%NOCOPY%'
group by 
   c.owner, c.type;
spool off
clear col
ttitle off
