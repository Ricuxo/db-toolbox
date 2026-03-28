select a.username as "USUARIO", a.sid as "SID", a.serial# as "SERIAL", b.spid as "PROCESSO", a.osuser as "USUARIO"
  from v$session a, v$process b
  where a.paddr=b.addr and a.username is not null
