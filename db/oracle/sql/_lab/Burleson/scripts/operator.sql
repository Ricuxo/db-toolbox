/*  */
rem
rem NAME: operator.sql
rem FUNCTION: Generate a lit of all OPERATORS in the database
rem for a specific user or all users
rem HISTORY: MRA 5/12/98 Created
rem
COLUMN owner             FORMAT a8   HEADING 'Owner'
COLUMN operator_name     FORMAT a10  HEADING 'Operator|Name'
COLUMN number_of_binds   FORMAT 9999 HEADING 'Binds'
COLUMN position                      HEADING 'Position'
COLUMN argument_type     FORMAT A10  HEADING 'Argument|Type'
COLUMN function_name     FORMAT A21  HEADING 'Bound|Function'
COLUMN return_schema     FORMAT A10  HEADING 'Return|Schema'
COLUMN return_type       FORMAT A10  HEADING 'Return|Type'
BREAK ON owner ON operator_name ON number_of_binds
SET PAGES 58 LINES 130 FEEDBACK OFF VERIFY OFF
START title132 'Database OPERATOR Report'
SPOOL rep_out\&db\operator.lis
SELECT 
     a.owner,
     a.operator_name,
     a.number_of_binds,
     b.position,
     b.argument_type,
     c.function_name,
     DECODE(c.return_schema,NULL,'Internal',c.return_schema) return_schema,
     c.return_type
FROM
     Dba_operators a, dba_oparguments b, dba_opbindings c
WHERE
         a.Owner LIKE '%&owner%'
     AND a.owner=b.owner
     AND a.operator_name=b.operator_name
     AND a.owner=c.owner
     AND a.operator_name=c.operator_name
     AND b.binding#=c.binding#;
SPOOL OFF
CLEAR BREAKS
CLEAR COLUMNS
TTITLE OFF
SET FEEDBACK ON VERIFY ON

