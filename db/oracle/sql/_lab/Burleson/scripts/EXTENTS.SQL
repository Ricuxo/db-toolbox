/*  */
REM
REM NAME                : EXTENTS7.SQL 
REM FUNCTION            : Generate extents report
REM USE                 : From SQLPlus or other front end
REM Limitations         : None
REM
CLEAR COLUMNS
column segment_name     heading 'Segment'     format a30
column tablespace_name  heading 'Tablespace'  format a20
column owner            heading 'Owner'       format a10
column segment_type	heading 'Type'		format a10
column size		heading 'Size'		format 9,999,999,999,999
set pagesize 40 NEWPAGE 0
SET LINESIZE 130 feedback off echo off newpage 0 verify off
accept extents prompt 'Enter max number of extents: '
BREAK ON TABLESPACE_NAME SKIP PAGE on owner
START title132 "EXTENTS REPORT"
DEFINE OUTPUT = rep_out\&db\extent
spool &OUTPUT
select  TABLESPACE_NAME,
	segment_name,
	EXTENTS "Extents",
	max_extents "Max Extents",
	BYTES "Size",
	OWNER "Owner",
	segment_type
FROM    DBA_SEGMENTS 
where extents >= &extents and owner like upper('%&owner%')
order by tablespace_name,owner,segment_type,segment_name;
SPOOL OFF
clear columns
clear breaks
set termout on feedback on verify on 
undef extents
undef owner
ttitle off
undef output
pause Press enter to continue

