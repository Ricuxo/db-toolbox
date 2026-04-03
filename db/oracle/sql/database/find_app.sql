SELECT
    s.inst_id AS INSTANCIA,
    s.sid AS SID,
    s.serial# AS SERIAL,
    s.username AS USUARIO_BD,
    s.osuser AS USUARIO_SO,
    s.machine AS MAQUINA_ORIGEM,
    s.program AS EXECUTAVEL,
    s.module AS MODULO,
    c.client_version AS VERSAO_CLIENT,
    c.client_driver AS TIPO_DRIVER,
    c.network_service_banner AS DETALHES_REDE
FROM gv$session s
JOIN gv$session_connect_info c
  ON s.sid = c.sid
 AND s.inst_id = c.inst_id
WHERE username is not null
and s.username not in (select username from dba_users where oracle_maintained='Y')
ORDER BY s.username,s.inst_id, s.sid;