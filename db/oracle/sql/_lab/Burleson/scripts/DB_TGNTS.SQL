/*  */
rem******************************************************************* 
rem  NAME: db_tgnts.sql      
rem 
rem  FUNCTION: Produce report of table or procedure grants showing 
rem  GRANTOR, GRANTEE or ROLE and specific GRANTS.  
rem 
rem  INPUTS: Owner name 
rem ******************************************************************** 
rem 
COLUMN grantee         FORMAT A18     HEADING "Grantee|or Role" 
COLUMN owner           FORMAT A18     HEADING "Owner" 
COLUMN table_name      FORMAT A30     HEADING "Table|or Proc" 
COLUMN grantor         FORMAT A18     HEADING "Grantor" 
COLUMN privilege       FORMAT A10     HEADING "Privilege" 
COLUMN grantable       FORMAT A19     HEADING "Grant|Option?" 
rem 
BREAK ON owner SKIP 4 ON table_name SKIP 1 ON grantee ON grantor ON REPORT 
rem 
SET LINESIZE 130 PAGES 56 VERIFY OFF FEEDBACK OFF 
START title132 "TABLE GRANTS BY OWNER AND TABLE" 
DEFINE OUTPUT = rep_out/&&db/db_tgnts 
SPOOL &output 
REM 
SELECT 
     owner, 
     table_name, 
     grantee, 
     grantor,  
     privilege, 
     grantable 
FROM 
     dba_tab_privs 
WHERE 
     owner NOT IN ('SYS','SYSTEM') 
ORDER BY 
     owner, 
     table_name, 
     grantor, 
     grantee; 
REM 
SPOOL OFF 
PAUSE Press enter to continue

