/*  */
rem
rem NAME: dim_level.sql
rem FUNCTION: Generate a lit of all Dimensions and levels in the 
rem database for a specific user or all users
rem HISTORY: MRA 5/12/98 Created
rem
COLUMN owner             FORMAT a8   HEADING 'Owner'
COLUMN dimension_name     FORMAT a10  HEADING 'Dimension|Name'
COLUMN level_name        FORMAT a10 HEADING 'Level|Name'
COLUMN column_name       FORMAT a20 HEADING 'Column|Name'
COLUMN key_position      FORMAT 9999 HEADING 'Key|Position'
BREAK ON owner ON operator_name ON number_of_binds
SET PAGES 58 LINES 130 FEEDBACK OFF VERIFY OFF
START title132 'Database Dimension Levels Report'
SPOOL rep_out\&db\dim_level.lis
SELECT 
     a.owner,
     a.dimension_name,
     b.level_name,
     c.column_name,
     c.key_position
FROM
     Dba_dimensions a, dba_dim_levels b, dba_dim_level_key c
WHERE
          a.Owner LIKE '%&owner%'
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

