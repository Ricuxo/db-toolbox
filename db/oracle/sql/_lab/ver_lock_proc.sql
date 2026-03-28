select session_id sid, owner, name, type,
         mode_held held, mode_requested request
    from dba_ddl_locks
   where session_id = (select sid from v$mystat where rownum=1)
/