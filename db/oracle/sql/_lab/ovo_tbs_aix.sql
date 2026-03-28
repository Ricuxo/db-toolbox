select instance_name, host_name from v$instance;
col String_tbs_monit for a100
col tablespace for a50
set feed off

create directory dir_ovo as '/var/lpp/OV/dbspi';

create table ovo_tbs
(
   tablespace varchar2(1000),
   limit varchar2(3), 
   perc_limit number(3)
)
organization external (
   type oracle_loader
   default directory DIR_OVO
   access parameters
   (
      records delimited by newline
      nobadfile 
      nologfile
      nodiscardfile
      fields terminated by " " lrtrim
      missing field values are null
      (
          tablespace,
          limit,
          perc_limit
      )
   )
   location ('tablespaces_monitored')
)
reject limit unlimited;

CREATE TABLE OVO_TBS_DB
AS
SELECT TABLESPACE_NAME TABLESPACE, ' LIM ' LIM, 
CASE
    when GIGAS < 101  then '15'
    when GIGAS < 501  then '10'
    else '5'
END as PERC_LIMIT
FROM
(
SELECT D.TABLESPACE_NAME, SUM(D.BYTES)/1024/1024/1024 GIGAS
FROM DBA_DATA_FILES D ,DBA_TABLESPACES T
WHERE D.TABLESPACE_NAME = T.TABLESPACE_NAME
AND   T.CONTENTS NOT IN ('UNDO','TEMPORARY')
GROUP BY D.TABLESPACE_NAME
)
ORDER BY TABLESPACE_NAME
/

create table ovo_tbs_diff
as
select o.*, b.tablespace||' LIM '||b.PERC_LIMIT String_tbs_monit
from ovo_tbs o, ovo_tbs_db b
where o.tablespace = b.tablespace
and o.perc_limit <> b.perc_limit;
set feed on
select * from ovo_tbs_diff;

prompt ovo-db
select tablespace from ovo_tbs
where tablespace not like '#%'
and tablespace <> 'DATABASE'
minus
select tablespace from ovo_tbs_db;

prompt bd-ovo
select tablespace||' LIM '||PERC_LIMIT String_tbs_monit
from ovo_tbs_db 
where tablespace not in (select tablespace from ovo_tbs_diff) 
minus
select tablespace||' LIM '||PERC_LIMIT String_tbs_monit from ovo_tbs;

set feed off
drop table ovo_tbs_diff;
drop table ovo_tbs_db;
drop table ovo_tbs;
drop directory dir_ovo;
set feed on
