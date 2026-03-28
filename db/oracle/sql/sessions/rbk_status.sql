--se uma transação está fazendo rollback depois de um kill 
--reparar na evolução do undo_records, menor rollback, maior atividade
--
col username for a40
SELECT a.sid, a.username, b.xidusn rollback_seg_no,
b.used_urec undo_records, b.used_ublk undo_blocks
FROM gv$session a, gv$transaction b
WHERE a.saddr = b.ses_addr
ORDER by sid;