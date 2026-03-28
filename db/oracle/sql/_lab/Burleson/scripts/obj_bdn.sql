/*  */
set lines 80 pages 47
@title80 'Object Breakdown by Owner'
spool rep_out\&db\obj_bkdwn
Select owner, object_type, count(*) num
    From dba_objects
    Group by owner, object_type;
spool off
ttitle off
