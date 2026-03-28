/*  */
SET ECHO OFF
SET FEEDBACK OFF
SET TIMING ON
-- *****************************************************************************
-- Script for analyzing the access path of a SQL-statement
-- Assuming the statement to be analyzed is contained
-- in the SQL-buffer of SQL*Plus and this SQL is executed using
-- the @ command in SQL*Plus. (i.e.. >SQL @<filename>
--------------------------------------------------------------------------------
-- FYI:  You must run UTLXPLAN.SQL or some variation of it
-- before using this SQL.  This SQL is designed
-- to be used with the original UTLXPLAN.SQL.  If a modified
-- version of UTLXPLAN.SQL is used, this file may need to be
-- modified as well.  You should also read about EXPLAIN
-- PLAN in the Oracle Documentation so that you can use this
-- information for your benefit.  Using EXPLAIN PLAN does not
-- execute the SQL statement being explained.  It only evaluates
-- the execution plan of the SQL statement.
--------------------------------------------------------------------------------
-- WARNING: If several users run this script simultaneously,
-- they might destroy each other's contents of PLAN_TABLE.
-- Therefore: Either create a separate copy of PLAN_TABLE,
-- or modify the script to include STATEMENT_ID
-- *****************************************************************************
-- Ehancements by Christian Adams 5/31 :
-- For each operation in the plan, the value of COST in PLAN_TABLE is the sum 
-- of 
--      1. the cost of the operation in question
--      2. the total cost of the child operations associated with it
-- 
-- This script will separate the cost for the operation from the total cost of 
-- its children.  The cost of the operations is displayed as "Cost", and the 
-- total cost of the children is displayed as "Subcost".  Furthermore, the 
-- cost/subcost is followed by its percentage of the total cost of the query in 
-- parentheses.
--------------------------------------------------------------------------------
-- MODIFICATIONS TO PLAN_TABLE:
-- For this script to work, you must add the following columns to your 
-- PLAN_TABLE: 
--
--      ALTER TABLE plan_table ADD mycost NUMBER NULL;
--      ALTER TABLE plan_table ADD mysubcost NUMBER NULL;
-- *****************************************************************************
-- First save the statement to be analyzed
SAVE "AFIEDT.BUF" REPLACE
-- Then clear PLAN_TABLE. Be aware that TRUNCATE implies COMMIT
TRUNCATE TABLE PLAN_TABLE;
-- Retrieve the statement to be analyzed
GET "AFIEDT.BUF" NOLIST
-- Put "EXPLAIN PLAN FOR" in front of statement
0 EXPLAIN PLAN FOR
-- Run the EXPLAIN
RUN

-- Get the total cost of the query from PLAN_TABLE.
COLUMN totcost NEW_VALUE totalcost NOPRINT
SELECT DECODE(cost,0,1,NULL,1,cost) totcost
FROM plan_table
WHERE id = 0
/

-- Separate the cost of each operation from the total cost of its children.
DECLARE
  v_subcost NUMBER;
  CURSOR cur_plan
  IS
  SELECT id, cost
  FROM plan_table FOR UPDATE
  ORDER BY id DESC;
BEGIN
  FOR c0 in cur_plan
  LOOP
    SELECT SUM(cost) INTO v_subcost
    FROM plan_table
    WHERE parent_id = c0.id;
    IF v_subcost IS NOT NULL THEN
      UPDATE plan_table
      SET mysubcost = v_subcost
      WHERE id=c0.id;
      IF c0.cost IS NULL THEN
        UPDATE plan_table
        SET cost = v_subcost
        WHERE CURRENT OF cur_plan;
      END IF;
    END IF;
  END LOOP;
  FOR c1 in cur_plan
  LOOP
    SELECT SUM(cost) INTO v_subcost
    FROM plan_table
    WHERE parent_id = c1.id;
    IF v_subcost IS NOT NULL THEN
      UPDATE plan_table
      SET mycost = cost - v_subcost
      WHERE id=c1.id;
    END IF;
  END LOOP;
  UPDATE plan_table
  SET mycost = cost
  WHERE mycost IS NULL;
  UPDATE plan_table
  SET mysubcost = cost
  WHERE mysubcost IS NULL;
  COMMIT;
END;
/

-- Display the execution plan.
BREAK ON access_path SKIP 1
SELECT LPAD(' ',4*(LEVEL-1))||OPERATION||' '||OPTIONS||' '
       ||OBJECT_NAME||' '||OBJECT_TYPE||' '||OPTIMIZER
       ||DECODE(ID,0,'  TotalCost='||&totalcost)
--       ||DECODE(COST,NULL,'','  OCost='||COST||' ('||ROUND(cost*100/&totalcost,2)||'%)')
       ||DECODE(mycost,NULL,'','  Cost='||mycost||' ('||ROUND(mycost*100/&totalcost,2)||'%)')
       ||DECODE(mysubcost,NULL,'','  Subcost='||mysubcost||' ('||ROUND(mysubcost*100/&totalcost,2)||'%)')
       ||DECODE(BYTES,NULL,'','  Bytes='||BYTES)
       ||DECODE(CARDINALITY,NULL,'','  Card='||CARDINALITY)
                 ACCESS_PATH
FROM   PLAN_TABLE
START WITH ID = 0 CONNECT BY PRIOR ID = PARENT_ID;
-- Restore original statement
GET "AFIEDT.BUF" NOLIST
SET FEEDBACK 1
SET ECHO ON
SET TIMING OFF
