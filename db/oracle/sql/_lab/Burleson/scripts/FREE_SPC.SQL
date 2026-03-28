/*  */
rem
rem Name:     free_spc.sql
rem
rem FUNCTION: Provide data on tablespace extent status
rem FUNCTION: this report uses the free_space view
rem
SET FEED OFF
SET FLUSH OFF
SET VERIFY OFF
set pages 58 LINES 130
column tablespace      heading Name              format a30
column file_id         heading File#             format 99999
column pieces          heading Frag              format 9999
column free_bytes      heading 'Free Byte'
column free_blocks     heading 'Free Blk'
column largest_bytes   heading 'Biggest Bytes'
column largest_blks    heading 'Biggest Blks'
column ratio           heading 'Percent'         format 999.999
start title132 "FREE SPACE REPORT"
define 1 = 'rep_out\&db\fre_spc'
spool &1
select tablespace,count(*) files,sum(pieces) pieces,sum(free_bytes) free_bytes,
sum(free_blocks) free_blocks,sum(largest_bytes) largest_bytes,
sum(largest_blks) largest_blks, sum(largest_bytes)/sum(free_bytes)*100 ratio 
from free_space
group by tablespace;
spool off
clear columns
pause Press Enter to Continue
SET FEED ON
SET FLUSH ON
SET VERIFY ON
set pages 22 LINES 80
clear columns
ttitle off
