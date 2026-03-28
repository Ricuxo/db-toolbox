/*  */
rem  ******************************************************
rem  NAME:  IN_ES_SZ.sql     
rem  HISTORY:
rem  Date           Who                    What
rem  --------       -------------------    ---------------
rem  01/20/93       Michael Brouillette    Creation
rem  09/22/01       Michael Ault           Upgraded to 9i
rem  FUNCTION:  Compute the space used by an entry for an 
rem   existing index.
rem  NOTES:  Currently requires DBA.
rem  INPUTS:
rem         tname  = Name of table.
rem         towner = Name of owner of table.
rem         clist  = List of columns enclosed in quotes.
rem                  i.e., 'ename', 'empno'
rem         cfile  = Name of output SQL Script file
rem  ******************************************************
COLUMN name      NEW_VALUE     db NOPRINT
COLUMN dum1      NOPRINT
COLUMN isize     FORMAT 99,999.99
COLUMN rcount    FORMAT 999,999,999 NEWLINE 
ACCEPT tname  PROMPT 'Enter table name: '
ACCEPT towner PROMPT 'Enter table owner name: '
ACCEPT clist  PROMPT 'Enter column list: '
ACCEPT cfile  PROMPT 'Enter name for output SQL file: '
SET HEADING OFF VERIFY OFF TERMOUT OFF PAGES 0 EMBEDDED ON
SET FEEDBACK OFF SQLCASE UPPER TRIMSPOOL ON SQLBL OFF
SET NEWPAGE 3
SELECT name FROM v$database;
SPOOL rep_out/&db/&cfile..sql
SELECT -1 dum1,
       'SELECT ''Proposed Index on table ''||' 
FROM dual
UNION
SELECT 0,
       '''&towner..&tname'||' has '',COUNT(*) rcount,
       '' entries of '', ('  
FROM dual 
UNION
SELECT column_id,
      'SUM(NVL(vsize('||column_name||'),0)) + 1 +'
FROM dba_tab_columns 
WHERE table_name = '&tname' 
   AND owner = '&towner'
   AND column_name in (upper(&clist))
   AND column_id <> (SELECT MAX(column_id)
                     FROM dba_tab_columns
                      WHERE table_name = UPPER('&tname') 
                        AND owner = UPPER('&towner')
                        AND column_name IN (upper(&clist))) 
UNION
SELECT column_id,
      'SUM(NVL(VSIZE('||column_name||'),0)) + 1)'
 FROM dba_tab_columns 
 WHERE table_name = upper('&tname')
   AND owner = upper('&towner') AND column_name IN (upper(&clist))
   AND column_id = (SELECT MAX(column_id)
                    FROM dba_tab_columns
                     WHERE table_name = upper('&tname')  
                      AND owner = upper('&towner')
                      AND column_name IN (upper(&clist))) 
UNION 
SELECT 997, '/ COUNT(*) + 11 isize, '' bytes each.''' 
FROM dual 
UNION 
SELECT 999,
       'FROM &towner..&tname.;'  FROM dual;
SPOOL OFF
SET TERMOUT ON FEEDBACK 15 PAGESIZE 20 SQLCASE MIXED 
SET NEWPAGE 1
START rep_out/&db/&cfile
CLEAR COLUMNS
