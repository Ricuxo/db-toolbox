/*  */
REM
REM NAME        : TABLE.SQL
REM FUNCTION    : GENERATE TABLE REPORT
REM Limitations : None
clear COLUMNs
COLUMN owner		 FORMAT a15	HEADING 'Table | Owner'
COLUMN table_name        FORMAT a18     HEADING Table
COLUMN tablespace_name   FORMAT A13 	HEADING Tablespace
COLUMN pct_increase 			HEADING 'Pct|Increase'
COLUMN init				HEADING 'Initial|Extent'
COLUMN next				HEADING 'Next|Extent'
COLUMN partitioned	 FORMAT a4	HEADING 'Par?'
COLUMN ini_trans         FORMAT 9999999      HEADING 'Initrans'
COLUMN freelists         FORMAT 9999999999      HEADING 'Freelists'
COLUMN temporary         FORMAT a5      HEADING 'Temp?'
BREAK ON owner ON tablespace_name
SET PAGES 48 LINES 132
START TITLE132 "ORACLE TABLE REPORT"
SPOOL rep_out\&db\tab_rep
SELECT 
	owner,
	tablespace_name,
	table_name,
	initial_extent Init,
	next_extent Next,
	pct_increase,
	partitioned,
        ini_trans,
        freelists,
	DECODE(temporary,'N','No','Yes') temporary
FROM 
	sys.dba_tables
WHERE 
	owner NOT IN  ('SYSTEM','SYS')
ORDER BY 
	owner,
	tablespace_name,
	table_name;
SPOOL OFF
CLEAR COLUMNS
PAUSE Press enter to continue
SET PAGES 22 LINES 80
TTITLE OFF
CLEAR COLUMNS
CLEAR BREAKS

