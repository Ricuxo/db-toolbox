/*  */
rem  **************************************************************************
rem  NAME: FKEYLIST.sql     
rem
rem  FUNCTION: This routine prints a report of all foreign keys defined in the
rem            data dictionary (for owners other than SYS and SYSTEM).  As 
rem            written, it must be run by a DBA.  By changing the query to run
rem            against ALL_CONSTRAINTS, etc. it could be used by any user to 
rem            see the foreign keys which are "available" to them.
rem  **************************************************************************
SET LINES 130 PAGES 56
rem
COLUMN OWNER  				FORMAT A10  NOPRINT NEW_VALUE OWNER_VAR
COLUMN TABLE_NAME    			FORMAT A24  HEADING'TABLE NAME'
COLUMN REF_TABLE         			FORMAT A24  HEADING'REF TABLE'
COLUMN R_OWNER           			FORMAT A10  NOPRINT
COLUMN CONSTRAINT_NAME  		FORMAT A30  HEADING 'CONST NAME'
COLUMN R_CONSTRAINT_NAME		FORMAT A30  NOPRINT
COLUMN COLUMN_NAME       			FORMAT A20  HEADING'COLUMN'
COLUMN REF_COLUMN       			FORMAT A20  HEADING'REF COLUMN'
rem
start title132 "FOREIGN KEY REPORT"
rem
BREAK ON OWNER SKIP PAGE ON TABLE_NAME SKIP 1 -
            ON CONSTRAINT_NAME ON REF_TABLE
SPOOL rep_out\&db\fkeylist
rem
SELECT 
	C.OWNER, 
	C.TABLE_NAME, 
	C.CONSTRAINT_NAME,
  	CC.COLUMN_NAME,
      	R.TABLE_NAME REF_TABLE, 
	RC.COLUMN_NAME REF_COLUMN
  FROM 
	DBA_CONSTRAINTS C, 
      	DBA_CONSTRAINTS R, 
        	DBA_CONS_COLUMNS CC,
         	DBA_CONS_COLUMNS RC
 WHERE 
	C.CONSTRAINT_TYPE = 'R' 
	AND C.OWNER NOT IN ('SYS','SYSTEM')
   	AND C.R_OWNER = R.OWNER 
   	AND C.R_CONSTRAINT_NAME = R.CONSTRAINT_NAME
   	AND C.CONSTRAINT_NAME = CC.CONSTRAINT_NAME
   	AND C.OWNER = CC.OWNER AND 
   	AND R.CONSTRAINT_NAME = RC.CONSTRAINT_NAME
   	AND R.OWNER = RC.OWNER 
	AND CC.POSITION = RC.POSITION
ORDER BY 
	C.OWNER, 
	C.TABLE_NAME, 
	C.CONSTRAINT_NAME, 
	CC.POSITION;
SPOOL OFF
clear breaks
clear columns
ttitle off
set lines 80 pages 22
