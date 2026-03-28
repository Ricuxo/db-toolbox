  SELECT a.username
        ,COUNT(b.object_name)
    FROM sys.dba_users a
         LEFT JOIN sys.dba_objects b ON a.username = b.owner
GROUP BY a.username
ORDER BY a.username;