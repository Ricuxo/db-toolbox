Rem
Rem    NOME
Rem      locks.sql  
Rem
Rem    DESCRIÇÃO
Rem      Este script lista as sessões com locks no banco de dados.      
Rem
Rem    UTILIZAÇÃO
Rem      @locks
Rem
Rem    ATUALIZAÇÕES  (MM/DD/YY)
Rem      FERR@RI      07/03/08 - criação do script
Rem
Rem ---------- ---------- ---------- ---------- ---------- ---------- ---------- ----------

set verify off

-- set serveroutput on size 1000000   
-- DECLARE   
--   CURSOR lcobj_cur IS
--      select session_id
--      ,      oracle_username
--      ,      os_user_name
--      ,      object_id obj_id
--      ,      locked_mode
--      from   gV$LOCKED_OBJECT ;
--      
--   CURSOR obj_cur(p_obj_id IN NUMBER) IS
--      select owner||'.'||object_name object_name
--      ,      object_type
--      from dba_objects
--      where object_id = p_obj_id;
--BEGIN
--   DBMS_OUTPUT.PUT_LINE(RPAD('Sid',5)||
--                        RPAD('O-User',10)||
--                        RPAD('OS-User',10)||
--                        RPAD('Owner.Object Name',45)||
--                        RPAD('Object Type',35));
--
--  DBMS_OUTPUT.PUT_LINE(RPAD('-',1,'-')||
--                        RPAD('-',6,'-')||
--                        RPAD('-',6,'-')||
--                        RPAD('-',41,'-')||
--                       RPAD('-',31,'-'));
--
--   FOR lcobj IN lcobj_cur
--   LOOP
--      FOR obj IN obj_cur(lcobj.obj_id)
--      LOOP
--         DBMS_OUTPUT.PUT_LINE(RPAD(lcobj.session_id,5)||
--                              RPAD(lcobj.oracle_username,10)||
--                              RPAD(lcobj.os_user_name,10)||
--                              RPAD(obj.object_name,45)||
--                              RPAD(obj.object_type,35));
--      END LOOP;
--   END LOOP;
--END;
--/


PROMPT
PROMPT ==> Blocked Objects from gV$LOCK and SYS.OBJ$

col BLOCKED_OBJ format a35 trunc
select
      l.sid, 
      l.lmode,
      TRUNC(l.ctime/60) min_blocked,
      u.name||'.'||o.NAME blocked_obj 
from (select * from gv$lock 
      where type='TM'
      and sid in (select sid from gv$lock where block!=0)) l,
      sys.obj$ o,
      sys.user$ u  
where o.obj# = l.ID1
and   o.OWNER# = u.user#
--and o.NAME='ITEM_ORDEM'
/


PROMPT
PROMPT ==> Blocked Sessions from gV$LOCK

col type for a28
col blocker_lockmode for a16
col blocked_request  for a16

select distinct
   blocker.inst_id blocker_inst,
   blocker.sid blocker_sid,
   blocked.sid blocked_sid,
   blocked.inst_id blocked_inst,
   TRUNC(blocked.ctime/60) min_blocked,
   decode(blocker.type, 'TX', 'TX - Transaction enqueue') as type,   
   decode(blocker.LMODE, 0, 'none', 
                         1, 'null (NULL)', 
                         2, 'row-S (SS)', 
                         3, 'row-X (SX)', 
                         4, 'share (S)', 
                         5, 'S/Row-X (SSX)', 
                         6, 'exclusive (X)'
         ) as blocker_lockmode, 
   decode(blocked.request, 0, 'none', 
                           1, 'null (NULL)', 
                           2, 'row-S (SS)', 
                           3, 'row-X (SX)', 
                           4, 'share (S)', 
                           5, 'S/Row-X (SSX)', 
                           6, 'exclusive (X)'
         ) as blocked_request,
   'alter system kill session '''||s.sid||','||s.serial#||''' immediate;' as Kill_session
from (select * from gv$lock 
      where block != 0 
      and type = 'TX') blocker,  
     gv$lock blocked,
     gv$session s
where blocked.type='TX' 
and blocked.block = 0
and blocked.id1 = blocker.id1
and blocker.sid = s.sid
and blocker.inst_id = s.inst_id
order by blocker.sid
/



set verify on