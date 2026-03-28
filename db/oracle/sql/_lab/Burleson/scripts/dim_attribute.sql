/*  */
rem
rem NAME: dim_attribute.sql
rem FUNCTION: Generate a lit of all Dimensions and atrributes in the 
rem database for a specific user or all users
rem HISTORY: MRA 5/12/98 Created
rem
COLUMN owner             FORMAT a8   HEADING 'Owner'
COLUMN dimension_name    FORMAT a10  HEADING 'Dimension|Name'
COLUMN column_name       FORMAT a20  HEADING 'Column|Name'
COLUMN level_name        FORMAT a20  HEADING 'Level|Name'
COLUMN inferred          FORMAT a10  HEADING 'Inferred'
BREAK ON owner ON level_name
SET PAGES 58 LINES 78 FEEDBACK OFF VERIFY OFF
START title80 'Database OPERATOR Report'
SPOOL rep_out\&db\dim_attribute.lis
SELECT 
     a.owner,
     a.dimension_name,
     b.level_name,
     c.column_name,
     c.inferred
FROM
     Dba_dimensions a, dba_dim_levels b, dba_dim_attributes c
WHERE
          a.owner LIKE '%&owner%'
      AND a.owner=b.owner
      AND a.dimension_name=b.dimension_name
      AND a.owner=c.owner
      AND a.dimension_name=c.dimension_name
      AND b.level_name=c.level_name
ORDER BY
      a.owner,
      a.dimension_name,
      b.level_name;
SPOOL OFF
CLEAR BREAKS
CLEAR COLUMNS
TTITLE OFF
SET FEEDBACK ON VERIFY ON

