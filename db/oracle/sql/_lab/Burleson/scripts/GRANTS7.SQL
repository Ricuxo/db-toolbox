/*  */
rem   
rem  NAME: GRANTS7.sql      
rem 
rem  PURPOSE: Produce report of table grants showing GRANTOR, GRANTEE and 
rem            	specific GRANTS.  
rem  LIMITATIONS: User must have access to DBA_TAB_PRIVS
rem  INPUTS: Owner name
rem  OUTPUTS: Report of table grants
rem
rem  HISTORY:
rem Who:	What:		Date:
rem Mike Ault	Initial Creation	3/2/95 
rem  
rem NOTES: Will not report grants to SYS or SYSTEM
rem
COLUMN GRANTEE  		FORMAT A18      HEADING "Grantee" 
COLUMN OWNER        	FORMAT A18      HEADING "Owner" 
COLUMN TABLE_NAME 	FORMAT A30      HEADING "Table" 
COLUMN GRANTOR     	FORMAT A18      HEADING "Grantor" 
COLUMN PRIVILEGE   	FORMAT A10      HEADING "Privilege" 
COLUMN GRANTABLE   	FORMAT A19      HEADING "With Grant Option?" 
REM
BREAK ON owner SKIP 4 ON table_name SKIP 1 ON grantee ON grantor ON REPORT 
REM 
SET LINESIZE 130 PAGES 56 VERIFY OFF FEEDBACK OFF 
START title132 "TABLE GRANTS BY OWNER AND TABLE" 
SPOOL rep_out\&db\grants 
REM 
SELECT 
	OWNER, 
	TABLE_NAME, 
	GRANTEE, 
	GRANTOR,  
	PRIVILEGE, 
	GRANTABLE 
  FROM 
	DBA_TAB_PRIVS 
 WHERE 
	OWNER NOT IN ('SYS','SYSTEM') 
        and GRANTEE='&GRANTEE'
 ORDER BY 
	OWNER, 
	TABLE_NAME, 
	GRANTOR, 
	GRANTEE; 
REM 
SPOOL OFF 
PAUSE Press enter to continue
SET LINESIZE 80 PAGES 22 VERIFY ON FEEDBACK ON 
clear breaks
clear columns
ttitle off

