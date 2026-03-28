@AWR

select wait_class_id, wait_class, count(*) cnt
from dba_hist_active_sess_history
where snap_id between &&begin_snap and &&end_snap
group by wait_class_id, wait_class
order by 3;

select event_id, event, count(*) cnt from dba_hist_active_sess_history
where snap_id between &&begin_snap and &end_snap and wait_class_id=&&wait_class_id
group by event_id, event
order by 3;

select sql_id, count(*) cnt from dba_hist_active_sess_history
where snap_id between &&begin_snap and &&end_snap
and event_id in (&&event_id)
group by sql_id
having count(*)>10
order by 2;

select sql_text from dba_hist_sqltext where sql_id='&sql_id';

select count(distinct(current_obj#)) from dba_hist_active_sess_history
where snap_id between &&begin_snap and &&end_snap
and event_id=&&event_id and sql_id='&&sql_id';

select current_obj#, count(*) cnt from dba_hist_active_sess_history
where snap_id between &&begin_snap and &&end_snap
and event_id=&&event_id and sql_id='&&sql_id'
group by current_obj#
order by 2;

select object_id, owner, object_name, subobject_name, object_type from dba_objects
where object_id in (&current_obj#_1, &current_obj#_2, &current_obj#_3);

undefine begin_snap;
undefine end_snap;
undefine sql_id;
undefine wait_class_id;
undefine event_id


