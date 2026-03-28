/*  */
rem  **************************************************************************
rem  NAME:     in_rep.sql 
rem  FUNCTION: Generate report on Indexes.
rem  INPUTS:
rem          1 = Oracle Account
rem          2 = Table name
rem  **************************************************************************
SET HEADING OFF VERIFY OFF PAUSE OFF
PROMPT **  Index Column Report  **
PROMPT 
PROMPT Percent signs are wild
ACCEPT OWNER CHAR PROMPT 'Enter Oracle account to report on (or wild): ';
ACCEPT TABLE_NAME CHAR PROMPT 'Enter table name to report on (or wild): ';	
PROMPT 
PROMPT Report file name is  INDEXES.LIS
SET HEADING ON
SET LINESIZE 130 PAGESIZE 56 NEWPAGE 0 SPACE 1 TAB OFF 
SET TERMOUT OFF 
BREAK ON TABLE_OWNER SKIP PAGE ON TABLE_TYPE ON TABLE_NAME ON UNIQUENESS ON INDEX_NAME SKIP 1 
COLUMN TABLE_OWNER     	FORMAT A25	HEADING 'Object Owner'    
COLUMN TABLE_TYPE     	FORMAT A6 	HEADING 'Type'    
COLUMN TABLE_NAME		FORMAT A30	HEADING 'Object Name'    
COLUMN INDEX_NAME		FORMAT A25	HEADING 'Index Name'    
COLUMN UNIQUENESS		FORMAT A1	HEADING 'U|N|I|Q|U|E'    
COLUMN COLUMN_NAME	FORMAT A30	HEADING 'Column Name'    
START TITLE132 "Index Columns by Owner and Table Name"                                        
SPOOL  rep_out\&db\indexes.LIS                      
SELECT   I.TABLE_OWNER
       , DECODE(TABLE_TYPE,'CLUSTER','CLUSTR','TABLE') TABLE_TYPE
       , I.TABLE_NAME, I.INDEX_NAME                                       
       , SUBSTR(UNIQUENESS,1,1) UNIQUENESS, IC.COLUMN_NAME, partitioned                     
    FROM DBA_INDEXES I, DBA_IND_COLUMNS IC
   WHERE I.INDEX_NAME = IC.INDEX_NAME
     AND OWNER = INDEX_OWNER  
     AND I.OWNER LIKE upper('&OWNER')
     AND I.TABLE_NAME LIKE upper('&TABLE_NAME')
ORDER BY 
     1,2,3,5 DESC,4,COLUMN_POSITION;                                                                              
SPOOL OFF
SET HEADING ON VERIFY ON PAUSE OFF TERMOUT ON
SET LINESIZE 80 PAGESIZE 22 TAB ON 
clear columns
clear breaks
undef owner
undef table_name
