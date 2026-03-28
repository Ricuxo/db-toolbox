select * from 
(
select instance_number, name,snap_id,to_char(snap_time,'DD.MM.YYYY:HH24:MI:SS')
     "Date/Time", snap_level 
from 
stats$snapshot,v$database
 where instance_number in (select instance_number from v$instance)
     order by snap_time desc
)
where rownum < 20;
