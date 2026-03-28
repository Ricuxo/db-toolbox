/*  */
col name format a30 heading 'Latch Name'
col gets format 99,999,999,999 heading 'Gets'
col misses format 9,999,999,999 heading 'Misses'
col sleeps format 999,999,999 heading 'Sleeps'
set pages 55
@title80 'Latches Contention Report'
spool rep_out\&db\latches_con
select name,gets,misses,sleeps from v$latch where gets>0 and misses>0 order by gets desc
/
spool off
clear columns
ttitle off
