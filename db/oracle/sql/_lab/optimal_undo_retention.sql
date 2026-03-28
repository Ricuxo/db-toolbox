---------------------------------------------------------------------------------
-- Script: optimal_undo_retention.sql
-- Author: Michael Messina, Management Consultant TUSC a Rolta Company
--
-- Description:  Will calculate based on undo utilization and undo size
--               the optimal value for undo_retention.
---------------------------------------------------------------------------------
set serveroutput on size 1000000
set feedback off

ACCEPT desired_undo_retention PROMPT "Enter Desired Undo Retention in Seconds ->"

DECLARE
   v_desired_undo_retention          NUMBER := &desired_undo_retention ;
   v_block_size                      NUMBER ;
   v_undo_size                       NUMBER ;
   v_undo_blocks_per_sec             NUMBER ;
   v_optimal_undo_retention          NUMBER ;
   v_current_undo_retention          NUMBER ;
   v_undo_size_desired_ret           NUMBER ;
  
BEGIN
   -- get the current undo retention setting
   select TO_NUMBER(value)
   INTO v_current_undo_retention
   FROM v$parameter
   WHERE name = 'undo_retention' ;
  
   -- Calculate Actual Undo Size
   SELECT SUM(a.bytes)
   INTO v_undo_size
   FROM v$datafile a,
        v$tablespace b,
        dba_tablespaces c
   WHERE c.contents = 'UNDO'
     AND c.status = 'ONLINE'
     AND b.name = c.tablespace_name
     AND a.ts# = b.ts#;

   -- Calcuate the Undo Blocks per Second
   SELECT MAX(undoblks/((end_time-begin_time)*3600*24))
   INTO v_undo_blocks_per_sec
   FROM v$undostat ;

   -- Get the database block size
   SELECT TO_NUMBER(value)
   INTO v_block_size
   FROM v$parameter
   WHERE name = 'db_block_size';

   v_optimal_undo_retention := v_undo_size/(v_block_size * v_undo_blocks_per_sec) ;
   v_undo_size_desired_ret := ((v_block_size * v_undo_blocks_per_sec) * (v_desired_undo_retention)) / 1024 / 1024 ;
  
   DBMS_OUTPUT.PUT_LINE ('              Current undo Size --> ' || TO_CHAR(v_undo_size/1024/1024) || 'MB') ;
   DBMS_OUTPUT.PUT_LINE (' Current undo_retention Setting --> ' || TO_CHAR(v_current_undo_retention) || ' Seconds') ;
   DBMS_OUTPUT.PUT_LINE (' Optimal undo_retention Setting --> ' || TO_CHAR(ROUND(v_optimal_undo_retention,2)) || ' Seconds') ;
   DBMS_OUTPUT.PUT_LINE (' Desired undo_retention Setting --> ' || TO_CHAR(ROUND(v_desired_undo_retention,2)) || ' Seconds') ;
   DBMS_OUTPUT.PUT_LINE ('Undo Size for desired retention --> ' || TO_CHAR(ROUND(v_undo_size_desired_ret,2)) || 'MB') ;
END ;
/

SELECT    'Number of "ORA-01555 (Snapshot too old)" encountered since
the last startup of the instance : '
       || SUM (ssolderrcnt)
  FROM v$undostat;