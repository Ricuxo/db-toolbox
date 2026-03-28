/*  */
rem
rem NAME: dim_hierarchies.sql
rem FUNCTION: Generate a lit of all dimensions and hierarchies in the 
rem database for a specific user or all users
rem HISTORY: MRA 5/12/98 Created
rem
COLUMN owner             FORMAT a8   HEADING 'Owner'
COLUMN dimension_name    FORMAT a10  HEADING 'Dimension|Name'
COLUMN column_name       FORMAT a10  HEADING 'Column|Name'
COLUMN hierarchy_name    FORMAT a10  HEADING 'Hierarchy|Name'
COLUMN parent_level_name FORMAT a10  HEADING 'Parent|Level'
COLUMN child_level_name  FORMAT a10  HEADING 'Child|Level'
COLUMN join_key_id       FORMAT a20 HEADING 'Join Key|ID'
BREAK ON owner ON dimension_name 
SET PAGES 58 LINES 78 FEEDBACK OFF VERIFY OFF
START title80 'Database Dimension Hierarchy Report'
SPOOL rep_out\&db\dim_hierarchies.lis
SELECT 
     a.owner,
     a.dimension_name,
     b.hierarchy_name,
     c.parent_level_name,
     c.child_level_name,
     c.join_key_id
FROM
     Dba_dimensions a, dba_dim_hierarchies b, dba_dim_child_of c
WHERE
          a.Owner LIKE '%&owner%'
      AND a.owner=b.owner
      AND a.dimension_name=b.dimension_name
      AND a.owner=c.owner
      AND a.dimension_name=c.dimension_name
      AND b.hierarchy_name=c.hierarchy_name
ORDER BY
      a.owner,
      a.dimension_name,
      b.hierarchy_name;
SPOOL OFF
CLEAR BREAKS
CLEAR COLUMNS
TTITLE OFF
SET FEEDBACK ON VERIFY ON

