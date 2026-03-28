/*  */
rem*************** RevealNet Oracle Administration ***********************
rem
rem  File: sga_dec.sql
rem
rem  This is a part of the RevealNet Oracle Administration library.
rem       
rem  All rights reserved.
rem
rem  For more information, call RevealNet at 1-800-REVEAL4
rem  or check out our Web page: www.revealnet.com
rem
rem  Modifications (Date, Who, Description)
rem
rem  FUNCTION:  Examine statistics in the X$KCBCBH table with intent 
rem             to shrink the SGA.
rem
rem ******************************************************************
rem
col bufval new_value nbuf noprint
col thits new_value tot_hits noprint

select value  bufval
from v$parameter
where
  lower(name) = 'db_block_buffers';
select sum(count) thits
from x$kcbcbh;
start title80 "Lost Hits if &nbuf Cache Buffers were Removed"

col interval   format         a20 justify c heading 'Buffers'
col cache_hits format 999,999,990 justify c heading -
  'Hits that would have been lost|had Cache Buffers been removed'
col cum format 99.99 heading 'Percent of loss'
set feedback off verify off echo off
spool rep_out\&db\sga_dec

select
	lpad(to_char(&&incr*trunc(indx/&&incr)+1,'999,990'),8)||' to '||
	lpad(to_char(&&incr*(trunc(indx/&&incr)+1),'999,990'),8) interval,
	sum(count)  cache_hits,
	sum(count)/&tot_hits * 100 cum
from
	x$kcbcbh
where
	indx > 0
group by
  trunc(indx/&&incr) ;

spool off
set termout on feedback 15 verify on
clear columns
clear computes
