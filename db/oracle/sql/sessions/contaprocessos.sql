SELECT
    s.schemaname,
    COUNT(DISTINCT p.pid) AS number_of_processes
FROM
    v$session s
JOIN
    v$process p ON s.paddr = p.addr
WHERE
    s.type = 'USER'
GROUP BY
    s.schemaname
ORDER BY
    s.schemaname;