/*  */
select s.osuser "O/S-User", s.username "Ora-User", s.sid "Session-ID",
  s.serial# "Serial", s.process "Process-ID", s.status "Status", r.name
  "Rollback", l.name "Obj Locked", l.mode_held "Lock Mode", t.log_io "Log
  I/O", t.phy_io "Phy I/O", t.used_ublk "undo blks", t.used_urec "undo recs",
  st.sql_text "Sql Text"
  from v$session s, v$transaction t, v$rollname r, v$process p, v$sqltext st,
  dba_dml_locks l
  where s.taddr = t.addr and l.session_id = s.sid and t.xidusn = r.usn and
  p.addr = s.paddr and s.sql_address = st.address and st.piece = 0
/
