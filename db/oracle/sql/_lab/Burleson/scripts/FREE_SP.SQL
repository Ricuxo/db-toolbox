/*  */
rem
rem Name:     free_spc2.sql
rem
rem FUNCTION: Provide data on tablespace extent status
rem FUNCTION: this report uses the free_space2 view
rem
SET FEED OFF
SET FLUSH OFF
SET VERIFY OFF
set pages 58 LINES 140
column tablespace      heading Name              format a30
column files		heading '#Files'	format 99,999
column pieces          heading Frag              format 99,999
column free_bytes      heading 'Free|Byte'	format 99,999,999,999
column free_blocks     heading 'Free|Blk'	format 9,999,999
column largest_bytes   heading 'Biggest|Bytes'	format 99,999,999,999
column largest_blks    heading 'Biggest|Blks'	format 9,999,999
column ratio           heading 'Percent'         format 999.999
column average_fsfi	heading 'Average|FSFI'	format 999.999
ttitle "FREE SPACE REPORT"
define 1 = 'fre_spc2'
spool &1
select tablespace,count(*) files,sum(pieces) pieces,sum(free_bytes) free_bytes,
sum(free_blocks) free_blocks,sum(largest_bytes) largest_bytes,
sum(largest_blks) largest_blks, sum(largest_bytes)/sum(free_bytes)*100 ratio,
sum(fsfi)/count(*) average_fsfi 
from free_space
group by tablespace;
spool off
clear columns
ttitle off
SET FEED ON
SET FLUSH ON
SET VERIFY ON
set pages 22 LINES 80
pause Press Enter to Continue

