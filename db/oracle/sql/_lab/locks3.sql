set pages 100
col WAIT_CLASS format a20
select
    sid,    
	serial#,
	STATUS,
	BLOCKING_SESSION_STATUS,
	BLOCKING_INSTANCE,
	BLOCKING_SESSION,
    wait_class,
    seconds_in_wait
from
    gv$session
where
    blocking_session is not NULL
and seconds_in_wait > 1
order by
    blocking_session;
