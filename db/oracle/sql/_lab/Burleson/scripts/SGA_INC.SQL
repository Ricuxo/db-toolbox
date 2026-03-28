/*  */
rem*************** RevealNet Oracle Administration ***********************
rem
rem  File: sga_inc.sql
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
rem  FUNCTION:  Examine statistics in the X$KCBRBH table with intent 
rem             to expand the SGA.
rem
rem ******************************************************************
rem
col bufval new_value nbuf noprint
col thits new_value tot_hits noprint

select value  bufval
from v$parameter
where
  lower(name) = 'db_block_lru_extended_statistics';
select sum(count) thits
from sys.x$kcbrbh;
start title80 "Gained Hits if &nbuf Cache Buffers are Added"

col interval   format         a20 justify c heading 'Buffers'
col cache_hits format 999,999,990 justify c heading -
  'Hits that would be gained|had Cache Buffers been added'
col cum format 99.99 heading 'Percent of Gain'
set feedback off verify off echo off
spool rep_out\&db\sga_inc

select
	lpad(to_char(&&incr*trunc(indx/&&incr)+1,'999,990'),8)||' to '||
	lpad(to_char(&&incr*(trunc(indx/&&incr)+1),'999,990'),8) interval,
	sum(count)  cache_hits
from
	sys.x$kcbrbh
where
	indx > 0
group by
  trunc(indx/&&incr) ;

spool off
set termout on feedback 15 verify on
clear columns
clear computes
