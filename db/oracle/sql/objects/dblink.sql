--
set lines 500
col host for a35
col db_link for a35
col owner for a20
col username for a30
-- 
select OWNER, 
       DB_LINK, 
       USERNAME, 
       HOST, 
       CREATED
from DBA_DB_LINKS
order by OWNER, DB_LINK;
--
prompt;
--