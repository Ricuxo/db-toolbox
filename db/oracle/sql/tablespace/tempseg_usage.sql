-- -----------------------------------------------------------------------------------
-- File Name    : http://www.oracle-base.com/dba/monitoring/tempseg_usage.sql
-- Author       : Tim Hall
-- Description  : Displays temp segment usage for all session currently using temp space.
-- Requirements : Access to the V$ views.
-- Call Syntax  : @tempseg_usage
-- Last Modified: 01/04/2006
-- -----------------------------------------------------------------------------------

SET LINESIZE 200
COLUMN username FORMAT A20

SELECT username,
       tablespace,
       session_addr,
       session_num,
       sqladdr,
       sqlhash,
       sql_id,
       contents,
       segtype,
       extents,
       blocks
FROM   v$tempseg_usage
ORDER BY username;




-----VER TEMP USAGE 2
SELECT ses.inst_id, ses.sid, ses.username, sort.tablespace, sort.segfile#, sort.blocks, ses.sql_id
FROM gv$sort_usage sort, gv$session ses
where sort.session_addr = ses.saddr
and ses.inst_id=sort.inst_id
ORDER BY blocks, 1, 2;