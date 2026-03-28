/*  */
--*************************************************
--    
--   Free for non-commercial use!  
--   To license, e-mail info@rampant.cc
-- ************************************************

break on wait_class skip 1

column event_name format a40
column wait_class format a20

select
  wait_class,
  event_name
from
  dba_hist_event_name
order by
  wait_class,
  event_name
;
