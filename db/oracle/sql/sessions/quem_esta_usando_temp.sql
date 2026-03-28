SELECT ses.inst_id, ses.sid, ses.username, sort.tablespace, sort.segfile#, sort.blocks, ses.sql_id
FROM gv$sort_usage sort, gv$session ses
where sort.session_addr = ses.saddr
and ses.inst_id=sort.inst_id
ORDER BY blocks, 1, 2;
