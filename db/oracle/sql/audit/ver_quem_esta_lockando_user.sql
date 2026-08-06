SELECT event_timestamp,
       dbusername,
       os_username,
       userhost,
       terminal,
       action_name,
       return_code,
       client_program_name,
       dblink_info
FROM   unified_audit_trail
WHERE  dbusername = 'PIX_PARTNER'
AND    return_code != 0
AND    event_timestamp >= SYSTIMESTAMP - INTERVAL '24' HOUR
ORDER  BY event_timestamp DESC;