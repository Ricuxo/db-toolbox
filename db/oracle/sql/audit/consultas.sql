SELECT 
    aud.os_user,
    aud.host_name,
    aud.client_program_name,
    aud.event_timestamp,
    CASE 
        WHEN aud.action = act.action THEN act.name
        ELSE 'Desconhecido'
    END AS action_name
FROM 
    audsys.aud$unified aud
JOIN 
    audit_actions act ON aud.action = act.action
    where aud.USERID='SYS' 
and aud.os_user <> 'oracle' 
and rownum < 100;