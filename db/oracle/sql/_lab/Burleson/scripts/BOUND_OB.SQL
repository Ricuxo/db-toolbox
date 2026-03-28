/*  */
rem  **************************************************************************
rem  NAME:    BOUND_OB.sql
rem  FUNCTION: Report on objects with extents bounded by freespace
rem  **************************************************************************
start title80 "Objects With Extents Bounded by Free Space"
spool rep_out\&db\b_ob..lis
column e format a15 heading "TABLE SPACE"
column a format a6 heading "OBJECT|TYPE"
column b format a30 heading "OBJECT NAME"
column c format a10 heading "OWNER ID"
column d format 99,999,999 heading "SIZE|IN BYTES"
break on e skip 1 on c 
rem set feedback off
set verify off
rem set termout off
column bls new_value BLOCK_SIZE noprint
select blocksize bls
from sys.ts$
where name='SYSTEM';

select h.name e, g.name c, f.object_type a, e.name b, b.length*&&block_size d
  from sys.uet$ b, sys.fet$ c, sys.fet$ d, sys.obj$ e, sys.sys_objects f, sys.user$ g, sys.ts$ h
 where b.block# = c.block# + c.length
   and b.block# + b.length = d.block#
   and f.header_file = b.segfile#
   and f.header_block = b.segblock#
   and f.object_id = e.obj#
   and g.user# = e.owner#
   and b.ts# = h.ts#
 order by 1,2,3,4
/

column a clear
column b clear
column c clear
column d clear
set feedback on 
set verify on
set termout on
ttitle ''
ttitle off
spool off
clear breaks
