--
--
--  NAME
--    eclcko.sql
--
--  DESCRIPTION
--    Mostra objetos em lock.
--
--  HISTORY
--    02/06/2008 => Eduardo Chinelatto
--
-----------------------------------------------------------------------------
set line 300
col sid format 999
col osuser format a15
col username format a12
col type format a4
col object_name format a20 wra
col object_type format a11 wra
col lmode format 99

set wrap off
set lines 130
set pages 100


select /*+ rule */ l.sid, s.serial#, s.osuser, s.username, l.type
     , o.object_name, o.object_type,l.lmode, ctime
from dba_objects o, v$lock l, v$session s
where l.id1 = o.object_id
and   l.sid = s.sid
and   s.username is not null
order by 1,9;

