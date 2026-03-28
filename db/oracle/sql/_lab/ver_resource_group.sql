SELECT schemaname, resource_consumer_group
FROM V$SESSION
WHERE schemaname not like 'SYS%'
