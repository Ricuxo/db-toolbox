-- 1. If your query was run within 30 minutes:

SELECT NAME,POSITION,DATATYPE_STRING,VALUE_STRING
FROM v$sql_bind_capture WHERE sql_id='';


-- 2. If your query was run more than 30 minutes ago. For this you also need a snapshot Id. By default oracle store snapshots of last 7 days:

SELECT NAME,POSITION,DATATYPE_STRING,VALUE_STRING
FROM DBA_HIST_SQLBIND WHERE SQL_ID='' and SNAP_ID='';