--|#########################################################################
--|# Program: Verifica se há locks no banco de dados
--|#  Author: Gilson Martins (gilson.martins@t-systems.com)
--|# Company: T-Systems do Brasil LTDA.
--|# Version: 1.0
--|#########################################################################

set line 300;
set pages 1000;

select s1.inst_id,s1.username || '@' || s1.machine
       || ' ( ALTER SYSTEM KILL SESSION ''' || s1.sid ||','||s1.serial#||''' immediate;  )  is blocking '
       || s2.username || ' ( SID=' || s2.sid || ' ) ' AS bl
  from v$lock l1, gv$session s1, gv$lock l2, gv$session s2
 where s1.sid=l1.sid and s2.sid=l2.sid
   and l1.BLOCK=1 and l2.request > 0
   and l1.id1 = l2.id1
   and l2.id2 = l2.id2;


-- select s1.username || '@' || s1.machine
--       || ' ( SID=' || s1.sid || ' )  is blocking '
--       || s2.username || '@' || s2.machine || ' ( SID=' || s2.sid || ' ) ' AS bl
--  from v$lock l1, v$session s1, v$lock l2, v$session s2
-- where s1.sid=l1.sid and s2.sid=l2.sid
--   and l1.BLOCK=1 and l2.request > 0
--   and l1.id1 = l2.id1
--   and l2.id2 = l2.id2;

PROMPT

--|## THE END ##|--
