set lines 120 set pages 60
col name form a30
col Last_Changed form a12
 
SELECT name,ptime "Last_Changed"
FROM sys.user$ a, dba_users b
where a.name=b.username
order by 1;
