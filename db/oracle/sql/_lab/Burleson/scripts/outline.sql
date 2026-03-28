/*  */
rem
rem NAME: outline.sql
rem FUNCTION: Generate a lit of all outlines in the 
rem database for a specific user or all users
rem HISTORY: MRA 5/13/98 Created
rem
COLUMN owner        FORMAT a8   HEADING 'Owner'
COLUMN name         FORMAT a13  HEADING 'Outline|Name'
COLUMN category     FORMAT a8  HEADING 'Category|Name'
COLUMN used         FORMAT a7   HEADING 'Used?'
COLUMN timestamp    FORMAT a16  HEADING 'Date Last|Used'
COLUMN version      FORMAT a9   HEADING 'Version'
COLUMN sql_text     FORMAT a40  HEADING 'SQL Outlined' WORD_WRAPPED 
BREAK ON owner ON category
SET PAGES 58 LINES 130 FEEDBACK OFF VERIFY OFF
START title132 'Database OUTLINE Report'
SPOOL rep_out\&db\outline.lis
SELECT 
     owner,
     name,
     category,
     used,
     to_char(timestamp,'dd/mm/yyyy hh24:mi') timestamp ,
     version,
     sql_text
FROM
     Dba_outlines 
WHERE
      Owner LIKE '%&owner%'
ORDER BY
      owner,category;
SPOOL OFF
CLEAR BREAKS
TTITLE OFF
SET FEEDBACK ON VERIFY ON

