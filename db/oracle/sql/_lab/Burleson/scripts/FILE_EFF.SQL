/*  */
REM NAME        : FILE_EFF.SQL 
REM PURPOSE     : GENERATE FILE IO EFFICIENCIES REPORT
REM USE         : FROM STATUS_REPORTS.COM
REM Limitations : MUST BE RUN FROM ORACLE DBA ACCOUNT 
REM
CLEAR COLUMNS
SET PAGES 58 NEWPAGE 0 
SET LINES 131
COLUMN EFF        FORMAT A6        HEADING '% Eff'
COLUMN RW         FORMAT 9,999,999,999 HEADING 'Phys Block|read+writes'
COLUMN TS         FORMAT A15           HEADING 'Tablespace|name'
COLUMN filename	  FORMAT a45	       heading 'File Name'
column disk       format a10
start title132 "FILE IO EFFICIENCY"
BREAK ON disk
compute sum of rw on disk
DEFINE OUTPUT = 'rep_out\&db\file_eff.lis'
spool &OUTPUT
select f.tablespace_name ts, substr(f.file_name,2,9) disk,
f.file_name filename,
v.phyblkrd+v.phyblkwrt rw,
to_char(decode (v.phyblkrd,0,null,
round(100*(v.phyrds+v.phywrts)/(v.phyblkrd+v.phyblkwrt),2))) eff
from dba_data_files f, v$filestat v
where f.file_id=v.file#
union
select ft.tablespace_name ts, substr(ft.file_name,2,9) disk,
ft.file_name filename,
vt.phyblkrd+vt.phyblkwrt rw,
to_char(decode (vt.phyblkrd,0,null,
round(100*(vt.phyrds+vt.phywrts)/(vt.phyblkrd+vt.phyblkwrt),2))) eff
from dba_temp_files ft, v$tempstat vt
where ft.file_id=vt.file#
order by disk;
spool off
ttitle off
set lines 80 pages 22
PAUSE Press enter to continue
