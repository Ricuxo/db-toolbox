set lin 150
set pages 150

SELECT acc.owner||'-> '||acc.constraint_name||'('||acc.column_name
||'['||acc.position||'])'||' ***** Missing Index' "Missing Index"
FROM all_cons_columns acc, all_constraints ac
WHERE ac.constraint_name = acc.constraint_name
AND ac.constraint_type = 'R'
and acc.owner not in ('SYSTEM','SYS','OLAPSYS','MDSYS','EXFSYS','ORDDATA')
AND (acc.owner, acc.table_name, acc.column_name, acc.position)
IN
(SELECT acc.owner, acc.table_name, acc.column_name, acc.position
FROM all_cons_columns acc, all_constraints ac
WHERE ac.constraint_name = acc.constraint_name
AND ac.constraint_type = 'R'
MINUS
SELECT table_owner, table_name, column_name, column_position
FROM dba_ind_columns)
ORDER BY acc.owner, acc.constraint_name,
acc.column_name, acc.position
/


set line 1000
set head off
set pagesize 0

select 'CREATE INDEX '||cons.owner||'.'||substr(cons.constraint_name,1,28)||'_I ON '||cons.owner||'.'||cons.table_name||'('||
cname1 || nvl2(cname2,','||cname2,null) ||
nvl2(cname3,','||cname3,null) || nvl2(cname4,','||cname4,null) ||
nvl2(cname5,','||cname5,null) || nvl2(cname6,','||cname6,null) ||
nvl2(cname7,','||cname7,null) || nvl2(cname8,','||cname8,null)||') PARALLEL 12  compute statistics online;' || chr(10) ||
'ALTER INDEX '||cons.owner||'.'||substr(cons.constraint_name,1,28)||'_I NOPARALLEL;'
from (select b.owner,
b.table_name,
b.constraint_name,
max(decode( position, 1, column_name, null )) cname1,
max(decode( position, 2, column_name, null )) cname2,
max(decode( position, 3, column_name, null )) cname3,
max(decode( position, 4, column_name, null )) cname4,
max(decode( position, 5, column_name, null )) cname5,
max(decode( position, 6, column_name, null )) cname6,
max(decode( position, 7, column_name, null )) cname7,
max(decode( position, 8, column_name, null )) cname8,
count(*) col_cnt
from (select owner,
substr(table_name,1,30) table_name,
substr(constraint_name,1,30) constraint_name,
substr(column_name,1,30) column_name,
position
from dba_cons_columns ) a,
dba_constraints b
where a.owner = b.owner
and a.owner not in ('SYSTEM','SYS','OLAPSYS','MDSYS','EXFSYS','ORDDATA','GSMADMIN_INTERNAL','LBACSYS','APEX_040200','DBSNMP')
and a.constraint_name = b.constraint_name
and b.constraint_type = 'R'
group by b.owner, b.table_name, b.constraint_name
) cons, dba_segments seg 
where  cons.owner = seg.owner 
  and  cons.table_name = seg.segment_name
  and  seg.segment_type='TABLE'
  AND  cons.col_cnt > ALL
( select count(*)
from dba_ind_columns i
where i.index_owner = cons.owner
and i.table_name = cons.table_name
and i.column_name in (cname1, cname2, cname3, cname4, cname5, cname6, cname7, cname8 )
and i.column_position <= cons.col_cnt
group by i.index_name
)
order by seg.bytes, cons.owner, cons.table_name;
set head on
set pagesize 10