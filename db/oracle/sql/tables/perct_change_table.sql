SET PAUSE ON
SET PAUSE 'Press Return to Continue'
SET PAGESIZE 60
SET LINESIZE 300
SET VERIFY OFF
 
-- *************************************************************************
-- * Enter a Valid Table Owner and a Valid Table Name.  (% for ALL Tables).
-- * Change Factor = High the Number, Greater the Change
-- *************************************************************************
 
COL table_name FOR A30
COL table_owner FOR A20
 
SELECT *
  FROM ( SELECT m.table_owner
              , m.table_name
              , t.last_analyzed
              , m.inserts
              , m.updates
              , m.deletes
              , t.num_rows
              , ( m.inserts + m.updates + m.deletes ) / CASE WHEN t.num_rows IS NULL OR t.num_rows = 0 THEN 1 ELSE t.num_rows END "Change Factor"
           FROM dba_tab_modifications m
              , dba_tables t
           WHERE t.owner = m.table_owner
             AND t.table_name = m.table_name
             AND m.inserts + m.updates + m.deletes > 1
             AND m.table_owner='&Enter_Table_Owner'
             AND m.table_name like '&Enter_Table_Name'
           ORDER BY "Change Factor" DESC
       )
/