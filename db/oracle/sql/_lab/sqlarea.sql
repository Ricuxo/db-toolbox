rem
rem FUNCTION: Generate a report of SQL Area Memory Usage
rem           showing SQL Text and memory catagories
rem
rem sqlmem.sql 
rem
COLUMN sql_text      FORMAT a60   HEADING Text word_wrapped
COLUMN sharable_mem               HEADING Shared|Bytes
COLUMN persistent_mem             HEADING Persistent|Bytes
COLUMN loads                      HEADING Loads
COLUMN users         FORMAT a15   HEADING "User"
COLUMN executions                 HEADING "Executions"
COLUMN users_executing            HEADING "Used By"
START title132 "Users SQL Area Memory Use"
SPOOL rep_out\&db\sqlmem
SET LONG 2000 PAGES 59 LINES 132
BREAK ON users
COMPUTE SUM OF sharable_mem ON USERS
COMPUTE SUM OF persistent_mem ON USERS
COMPUTE SUM OF runtime_mem ON USERS
SELECT 
username users, sql_text, Executions, loads, users_executing, 
sharable_mem, persistent_mem 
FROM 
sys.v_$sqlarea a, dba_users b
WHERE 
a.parsing_user_id = b.user_id
AND b.username LIKE UPPER('%&user_name%')
ORDER BY 3 DESC,1;
SPOOL OFF
PAUSE Press enter to continue
CLEAR COLUMNS
CLEAR COMPUTES
CLEAR BREAKS
SET PAGES 22 LINES 80