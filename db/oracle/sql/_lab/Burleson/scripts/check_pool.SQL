/*  */
REM Check_pool.sql
REM Mike Ault   Burleson Consulting  6/26 
REM FUNCTION: This script runs several SQL scripts that
REM FUNCTION: check on the health of the shared pool
clear columns
clear computes
ttitle off
@test_pool
clear columns
clear computes
ttitle off
@sql_garbage3
ttitle off
clear columns
clear computes
@reuse_sql2
ttitle off
clear columns
clear computes


