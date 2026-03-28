rem
rem     Script:         resource_limit.sql
rem     Author:         Jonathan Lewis
rem     Dated:          Feb 2007
rem
 
set linesize 180
set pagesize 60
set trimspool on
 
column resource_name            format a32
column max_utilization          format 999,999
column current_utilization      format 999,999
column initial_allocation       format a18
column limit_value              format a11
 
select
        resource_name,
        max_utilization,
        current_utilization,
        lpad(initial_allocation,18)     initial_allocation,
        lpad(limit_value,11)            limit_value
from
        v$resource_limit
;
