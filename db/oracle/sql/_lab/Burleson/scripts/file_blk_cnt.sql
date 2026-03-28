/*  */
col object heading 'Object Name'
col file# heading 'File|Number'
col touches heading 'Touches'
@title80 'SGA Block Usage For File &&file_no'
spool rep_out\&db\file_blk_cnt
select
b.name object,
a.dbarfil file#,
count(a.dbablk) "Num blocks",
sum(a.tch) "Touches"
from x$bh a, obj$ b
where a.obj=b.dataobj# 
and a.tch>0
and a.file#=&&file_no
group by b.name,a.dbarfil
order by 4 desc
/
spool off
ttitle off
clear columns
undef file_no

