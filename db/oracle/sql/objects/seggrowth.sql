REM 
REM $Header: seggrowth.sql 1.0.0 2025/10/07 marcus.v.pedro $
REM
REM Copyright (c) 2025, All rights reserved.
REM
REM AUTHOR
REM   Marcus Vinicius Miguel Pedro
REM   Accenture Enkitec Group
REM   https://www.viniciusdba.com.br/blog
REM   https://www.linkedin.com/in/viniciusdba
REM
REM SCRIPT
REM   seggrowth.sql
REM
REM DESCRIPTION
REM   This script shows the top-20 segments that growh per month
REM
REM PRE-REQUISITES
REM   1. Be granted with SELECT_ANY_DICTIONARY privilege.
REM
REM EXECUTION
REM   1. Connect into SQL*Plus as user with access to data dictionary
REM   2. Execute script seggrowth.sql 
REM
REM EXAMPLE
REM   # sqlplus system
REM   SQL> START seggrowth.sql 
REM
REM NOTES
REM   1. This script works on 10g or higher
REM


break on rnk on owner on object_name
SET LINES 200 PAGES 200 

COL owner             FORMAT A15
COL object_name       FORMAT A30
COL start_month       FORMAT A7
COL current_size_gb   FORMAT 999,999,999.90
COL increase_gbytes   FORMAT 999,999,999.90
COL pct_increase      FORMAT 999,999.90
COL rnk               FORMAT 99

WITH monthly_increases AS (
    SELECT
        o.owner,
        o.object_name,
        TO_CHAR(sn.begin_interval_time,'RRRR-MM') start_month,
        SUM(a.space_allocated_delta)/1024/1024/1024 increase_gbytes
    FROM dba_hist_seg_stat a,
         dba_hist_snapshot sn,
         dba_objects o
    WHERE sn.snap_id = a.snap_id
      AND o.object_id = a.obj#
      AND o.object_type in ('TABLE','LOB')
    GROUP BY o.owner, o.object_name, TO_CHAR(sn.begin_interval_time,'RRRR-MM')
),
current_sizes AS (
    SELECT owner,
           segment_name object_name,
           SUM(bytes)/1024/1024/1024 current_size_gb
    FROM dba_segments
    WHERE segment_type in ('TABLE','LOBSEGMENT')
    GROUP BY owner, segment_name
),
total_increases AS (
    SELECT owner, object_name,
           SUM(increase_gbytes) total_increase
    FROM monthly_increases
    GROUP BY owner, object_name
)
SELECT *
FROM (
    SELECT
        DENSE_RANK() OVER (ORDER BY ti.total_increase DESC) rnk,
		mi.owner,
        mi.object_name,
        mi.start_month,
        mi.increase_gbytes,
        cs.current_size_gb - NVL(SUM(mi.increase_gbytes) OVER (
            PARTITION BY mi.owner, mi.object_name
            ORDER BY mi.start_month
            ROWS BETWEEN 1 FOLLOWING AND UNBOUNDED FOLLOWING
        ), 0) current_size_gb,
        CASE
            WHEN (cs.current_size_gb - NVL(SUM(mi.increase_gbytes) OVER (
                PARTITION BY mi.owner, mi.object_name
                ORDER BY mi.start_month
                ROWS BETWEEN 1 FOLLOWING AND UNBOUNDED FOLLOWING
            ), 0) - mi.increase_gbytes) > 0
            THEN (mi.increase_gbytes / (cs.current_size_gb - NVL(SUM(mi.increase_gbytes) OVER (
                PARTITION BY mi.owner, mi.object_name
                ORDER BY mi.start_month
                ROWS BETWEEN 1 FOLLOWING AND UNBOUNDED FOLLOWING
            ), 0) - mi.increase_gbytes)) * 100
        END pct_increase       
    FROM monthly_increases mi,
         current_sizes cs,
         total_increases ti
    WHERE mi.owner = cs.owner
      AND mi.object_name = cs.object_name
      AND mi.owner = ti.owner
      AND mi.object_name = ti.object_name
      AND cs.current_size_gb > 5
      AND mi.increase_gbytes > 0
)
WHERE rnk <= 20
  AND current_size_gb > 0
ORDER BY rnk, owner, object_name, start_month;

