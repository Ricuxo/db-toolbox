/*  */
rem
rem Name:     free_spc.sql
rem
rem FUNCTION: Provide data on tablespace extent status
rem FUNCTION: this report uses the free_space view
rem
rem Mike Ault Burleson Consulting
rem
SET FEED OFF
SET FLUSH OFF
SET VERIFY OFF
set pages 58 LINES 130
column tablespace      heading Name              format a30
column file_id         heading File#             format 99999
column pieces          heading Frag              format 9999
column free_bytes      heading 'Free Meg'       format 99,999.99
column largest_bytes   heading 'Biggest|Free Meg' format 99,999.99
column ratio           heading 'Percent of|Free Meg'         format 999.999
column total_meg        heading 'Total|Meg'     format 99,999.999
column used_meg		heading 'Total|Used Meg'	format 99,999,999.99
column meg_ratio        heading 'Percent Free|Total Meg'     format 999.99
break on total_meg on used_meg
compute sum of total_meg on report 
compute sum of used_meg on report
start title132 "FREE SPACE REPORT"
define 1 = 'rep_out\&&db\fre_spc'
spool &1
select a.tablespace,count(a.tablespace) files,sum(a.pieces) pieces,
sum(a.free_bytes)/1048576 free_bytes,
sum(a.largest_bytes)/1048576 largest_bytes,
sum(a.largest_bytes)/sum(a.free_bytes)*100 ratio,
DBA_UTILITIES.get_bytes(a.tablespace)/1048576 Total_meg, 
(DBA_UTILITIES.get_bytes(a.tablespace)/1048576)-(sum(a.free_bytes)/1048576) used_meg,
(sum(a.free_bytes)/DBA_UTILITIES.get_bytes(a.tablespace)*100) meg_ratio
from free_space a
group by tablespace
order by tablespace, total_meg, used_meg;
spool off
clear columns
pause Press Enter to Continue
SET FEED ON
SET FLUSH ON
SET VERIFY ON
set pages 22 LINES 80
clear columns
ttitle off
