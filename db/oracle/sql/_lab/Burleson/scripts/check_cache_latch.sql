/*  */
rem from metalink
rem
@title80 'Cache Latches'
spool rep_out\&db\cache_latch
spool check_cache_latch
select count(*), event from v$session_wait
       where state='WAITING' group by event order by 1 desc;

select count(*), name latchname from v$session_wait, v$latchname
       where event='latch free' and state='WAITING' and p2=latch#
       group by name order by 1 desc;
spool off
ttitle off
