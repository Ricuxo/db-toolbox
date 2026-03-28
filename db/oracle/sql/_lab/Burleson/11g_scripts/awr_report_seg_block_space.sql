/*  */
--*************************************************
--    
--   Free for non-commercial use!  
--   To license, e-mail info@rampant.cc

col seg_owner heading 'Segment|Owner' format a10
col seg_type heading 'Segment|Type'   format a10
col seg_name heading 'Segment|Name'   format a30

col fs1 heading '0-25%|Free Space'    format 9,999
col fs2 heading '25-50%|Free Space'   format 9,999
col fs3 heading '50-75%|Free Space'   format 9,999
col fs4 heading '75-100%|Free Space'  format 9,999
col fb  heading 'Full|Blocks'         format 9,999

accept user_name prompt 'Enter Segment Owner: '

break on seg_owner

select
  *
from
  Table ( BlckFreeSpaceFunc ('&user_name', 'TABLE' ) )
order by
  fs4 desc
;
