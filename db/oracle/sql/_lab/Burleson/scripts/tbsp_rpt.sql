/*  */
COL TABLESPACE FORMAT A20
@TITLE132 'Tablespace Parameters'
set lines 132
spool rep_out\&&db\tbsp_rpt
select 
tablespace_NAME TABLESPACE, 
	INITIAL_EXTENT INIT, 
	NEXT_EXTENT NEXT,
	MIN_EXTENTS MIN, 
	MAX_EXTENTS MAX, 
	PCT_INCREASE PCT_INC 
FROM DBA_TABLESPACES
/
spool off
