/*  */
rem  *******************************************************
rem
rem  NAME:  IN_CM_SZ.sql     
rem
rem  HISTORY:
rem  Date             Who              What
rem  --------- -------------------  ----------
rem  01/20/93  Michael Brouillette  Creation
rem  09/22/01  Mike Ault            Updated to 9i
rem    
rem  FUNCTION:  Compute the space used by an entry for an 
rem     existing index.
rem
rem  NOTES:  Currently requires DBA.
rem
rem  INPUTS:
rem         tname  = Name of table.
rem         towner = Name of owner of table.
rem         iname  = Name of index.
rem         iowner = Name of owner of index.
rem         cfile  = Name of output file SQL Script.
rem  *******************************************************
COLUMN dum1       NOPRINT
COLUMN isize      FORMAT 999,999,999.99
COLUMN rcount     FORMAT 999,999,999 NEWLINE
ACCEPT tname  PROMPT 'Enter table name: '
ACCEPT towner PROMPT 'Enter table owner name: '
ACCEPT iname  PROMPT 'Enter index name: '
ACCEPT iowner PROMPT 'Enter index owner name: '
ACCEPT cfile  PROMPT 'Enter name for output SQL file: '
SET PAGESIZE 0 HEADING OFF VERIFY OFF TERMOUT OFF 
SET FEEDBACK OFF TRIMSPOOL ON SQLBL OFF
SET SQLCASE UPPER NEWPAGE 3
SPOOL &cfile..sql
SELECT -1 dum1,
       'SELECT ''Index '||'&iowner..&iname'||' on table '
  FROM dual
UNION
SELECT 0,
       '&towner..&tname'||' has '',
       nvl(COUNT(*),0) rcount,'' entries of '', (' 
  FROM dual
UNION
SELECT column_id,
      'SUM(NVL(vsize('||column_name||'),0)) + 1 +' 
  FROM dba_tab_columns 
 WHERE table_name = '&tname'
   AND owner = upper('&towner') AND column_name IN
                   (SELECT column_name FROM dba_ind_columns 
                     WHERE table_name = upper('&tname')
                       AND table_owner = upper('&towner')
                       AND index_name = upper('&iname')
                       AND index_owner = upper('&iowner'))
                       AND column_id <> (select max(column_id)
                                        FROM dba_tab_columns
                                        WHERE table_name = upper('&tname')
                                        AND owner = upper('&towner')
                                        AND column_name IN
                      (SELECT column_name FROM dba_ind_columns 
                        WHERE table_name = upper('&tname')
                          AND table_owner = upper('&towner')
                          AND index_name = upper('&iname')
                          AND index_owner = upper('&iowner')))
UNION
SELECT column_id,
      'SUM(NVL(vsize('||column_name||'),0)) + 1)'
  FROM dba_tab_columns 
  WHERE table_name = upper('&tname') AND owner = upper('&towner')
   AND column_name IN
                   (SELECT column_name FROM dba_ind_columns 
                     WHERE table_name = upper('&tname')
                       AND table_owner = upper('&towner')
                       AND index_name = upper('&iname')
                       AND index_owner = upper('&iowner'))
                       AND column_id = (SELECT MAX(column_id)
                     FROM dba_tab_columns
                     WHERE table_name = upper('&tname') 
                      AND owner = upper('&towner')
                      AND column_name IN
                      (SELECT column_name FROM dba_ind_columns 
                        WHERE table_name = upper('&tname')
                          AND table_owner = upper('&towner')  
                          AND index_name = upper('&iname')
                          AND index_owner = upper('&iowner')))
UNION 
SELECT 997,
       '/ COUNT(*) + 11 isize, '' bytes each.'''  from dual
UNION 
SELECT 999,  'FROM &towner..&tname.;'  FROM dual;
SPOOL OFF
SET TERMOUT ON FEEDBACK 15 PAGESIZE 20 SQLCASE MIXED 
SET NEWPAGE 1
START &cfile
CLEAR columns
UNDEF tname
UNDEF towner
UNDEF iname
UNDEF iowner
UNDEF cfile
