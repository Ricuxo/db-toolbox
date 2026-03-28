/*  */
rem
rem NAME: outline_hint.sql
rem FUNCTION: Generate a lit of all outlines in the 
rem database for a specific user and outline or all users
rem and outlines
rem HISTORY: MRA 5/13/98 Created
rem
COLUMN owner        FORMAT a8   HEADING 'Owner'
COLUMN name         FORMAT a13  HEADING 'Outline|Name'
COLUMN category     FORMAT a10  HEADING 'Category|Name'
COLUMN node         FORMAT 9999 HEADING 'Node'
COLUMN join_pos     FORMAT 9999 HEADING 'Join|Pos'
COLUMN hint         FORMAT A27  HEADING 'Hint Text' WORD_WRAPPED
BREAK ON owner ON category ON name
SET PAGES 58 LINES 78 FEEDBACK OFF VERIFY OFF
START title80 'Database OUTLINE Report'
SPOOL rep_out\&db\outline_hint.lis
SELECT 
     a.owner,
     a.name,
     a.category,
     b.node,
     b.join_pos,
     b.hint
FROM
     Dba_outlines a, dba_outline_hints b 
WHERE
      a.Owner LIKE UPPER('%&owner%')
      AND a.name LIKE UPPER('%&outline%')
      AND a.owner=b.owner
      AND a.name=b.name
ORDER BY
      owner,category,name,b.node;
SPOOL OFF
CLEAR BREAKS
TTITLE OFF
SET FEEDBACK ON VERIFY ON

