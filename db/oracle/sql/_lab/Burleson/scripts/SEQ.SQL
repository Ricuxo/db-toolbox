/*  */
rem  NAME: Seq.sql
rem
rem  FUNCTION: Generate a report on sequences for an account
rem		
rem  INPUTS:
rem
rem			1 - Sequence Owner or Wild Card
rem			2 - Sequence Name or Wild Card
rem
rem  **************************************************************************
SET HEADING OFF VERIFY OFF PAUSE OFF
rem
PROMPT ** Sequence Report **
PROMPT
PROMPT Percent signs are wild
rem
ACCEPT sequence_owner prompt 'Enter Oracle account to report on (or wild):';
ACCEPT sequence_name prompt 'Enter object name to report on (or wild): ';
PROMPT
PROMPT Report file name is sequence_dbname.lis
rem
SET HEADING ON	
SET LINESIZE 130 PAGESIZE 56 NEWPAGE 0 TAB OFF SPACE 1 
SET TERMOUT OFF
BREAK ON SEQUENCE_OWNER SKIP 2
rem
COLUMN SEQUENCE_OWNER 	FORMAT A10	HEADING 'Sequence Owner'
COLUMN SEQUENCE_NAME		FORMAT A30	HEADING 'Sequence Name'
COLUMN MIN_VALUE					HEADING 'Minimum'
COLUMN MAX_VALUE					HEADING 'Maximum'
COLUMN INCREMENT_BY		FORMAT 9999	HEADING 'Incr.'
COLUMN CYCLE_FLAG        				HEADING 'Cycle'
COLUMN ORDER_FLAG					HEADING 'Order'
COLUMN CACHE_SIZE		FORMAT 99999	HEADING 'Cache'
COLUMN LAST_NUMBER					HEADING 'Last Value'
rem
START title132 "SEQUENCE REPORT"
SPOOL rep_out\&db\sequence
rem
SELECT  
	SEQUENCE_OWNER, 
	SEQUENCE_NAME, 
	MIN_VALUE, 
	MAX_VALUE,
	INCREMENT_BY, 
	DECODE(CYCLE_FLAG,'Y','YES','N','NO') CYCLE_FLAG,
	DECODE(ORDER_FLAG,'Y','YES','N','NO') ORDER_FLAG,
	CACHE_SIZE, 
	LAST_NUMBER
FROM 	
	DBA_SEQUENCES
WHERE  
	SEQUENCE_OWNER LIKE UPPER('&SEQUENCE_OWNER') AND
	SEQUENCE_NAME LIKE UPPER('&SEQUENCE_NAME')
ORDER BY  
	1,2;
SPOOL OFF
pause Press Enter to continue
set echo on heading on verify on feedback on tab on lines 80 pages 22
set termout on
clear columns
ttitle off
                                                                                                                    
