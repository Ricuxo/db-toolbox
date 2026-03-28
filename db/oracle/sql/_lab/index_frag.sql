-- +------------------------------------------------------------------------------+
-- | PURPOSE  : To check for index fragmentation. As a rule of thumb if 10-15%  |
-- |            of the table data changes, then you should consider rebuilding the index  |
-- +-------------------------------------------------------------------------------+

ANALYZE INDEX &&index_name VALIDATE STRUCTURE;

COL name         HEADING 'Index Name'          FORMAT a30
COL del_lf_rows  HEADING 'Deleted|Leaf Rows'   FORMAT 99999999
COL lf_rows_used HEADING 'Used|Leaf Rows'      FORMAT 99999999
COL ibadness     HEADING '% Deleted|Leaf Rows' FORMAT 999.99999

SELECT
    name
  , del_lf_rows
  , lf_rows - del_lf_rows lf_rows_used
  , TO_CHAR( del_lf_rows /(DECODE(lf_rows,0,0.01,lf_rows))*100,'999.99999') ibadness
FROM   index_stats
/

prompt
prompt Consider rebuilding any index if % of Deleted Leaf Rows is > 20%
prompt

undefine index_name 